using Gee;

namespace Tuner {

    public class App : Adw.Application {
        private const ActionEntry[] APP_ENTRIES = {
            { "open-app-page", open_app_page },
            { "import", import },
            { "export", export },
            { "plugin-list", open_plugin_list },
            { "restart", restart_app },
            { "about", about_activated },
            { "quit", quit }
        };

        private PageList pages;
        private MainWindow main_window;

        public static Peas.ExtensionSet addins;
        public static Settings settings;

        private static App _instance;
        public static App instance {
            get {
                if (_instance == null)
                    _instance = new App();

                return _instance;
            }
        }

        construct {
            application_id = ID;
            flags = ApplicationFlags.HANDLES_COMMAND_LINE;
        }

        public override void startup() {
            base.startup();

            typeof(AnimationBin).ensure();

            settings = new Settings("org.altlinux.Tuner");

            var engine = Peas.Engine.get_default();
            engine.enable_loader("python");

            engine.add_search_path(
                Path.build_filename(LIBDIR, "tuner", "plugins"),
                Path.build_filename(DATADIR, "plugins")
            );
            var user_plugins = Path.build_filename(Environment.get_user_data_dir(), "tuner", "plugins");
            engine.add_search_path(user_plugins, null);

            load_search_path(engine);

            addins = new Peas.ExtensionSet.with_properties(engine, typeof(Addin), {}, {});

            set_accels_for_action("app.quit", { "<Ctrl>Q" });
            add_action_entries(APP_ENTRIES, this);
        }

        public override void activate() {
            if (main_window != null) {
                main_window.present();
                return;
            }

            main_window = new MainWindow(this);

            if (addins.get_n_items() > 0)
                main_window.load_pages(pages);

            main_window.present();
        }

        public override int command_line(ApplicationCommandLine command_line) {
            load_extensions();

            var args = command_line.get_arguments();
            if (args.length > 1) {
                var positional_arg = args[1];

                return CommandUtil.handle_command_line(pages, command_line, positional_arg);
            }
            activate();
            return 0;
        }

        private void load_search_path(Peas.Engine engine) {
            var env = Environment.get_variable("PLUGIN_SEARCH_PATH");

            if (env != null) foreach (var path in env.split(":")) {
                engine.add_search_path(path, null);
            }
        }

        private void import() {
            import_async.begin();
        }

        private void export() {
            export_async.begin();
        }

        private async void import_async() {
            var picker = new Gtk.FileDialog();

            try {
                var file = yield picker.open(main_window, null);

                if (file != null) {
                    if (file.query_exists()) {
                        var parser = new Json.Parser();
                        yield parser.load_from_stream_async(file.read());

                        var node = parser.get_root();

                        if (node != null) {
                            ConfigUtil.import_config(pages, node);
                            Tuner.toast("Configuration imported.");
                            return;
                        }
                    }
                }
            } catch (Error err) {
                if (err.code == Gtk.DialogError.DISMISSED) return;
                warning(@"Failed to import: $(err.message)");
            }

            Tuner.toast("Failed to import configuration.");
        }

        private async void export_async() {
            var picker = new Gtk.FileDialog();

            try {
                var file = yield picker.save(main_window, null);

                if (file != null) {
                    var stream = yield file.replace_async(null, false, FileCreateFlags.NONE, Priority.DEFAULT, null);
                    var generator = new Json.Generator();

                    generator.root = ConfigUtil.export_config(pages);
                    generator.to_stream(stream, null);

                    Tuner.toast("Configuration saved.");
                    return;
                }
            } catch (Error err) {
                if (err.code == Gtk.DialogError.DISMISSED) return;
                warning(@"Failed to export: $(err.message)");
            }

            Tuner.toast("Failed to export configuration.");
        }

        private void open_plugin_list() {
            new PluginsDialog().present(main_window);
        }

        private void about_activated() {
            var dialog = new Adw.AboutDialog.from_appdata("org/altlinux/Tuner/org.altlinux.Tuner.metainfo.xml", VERSION) {
                copyright = "© 2025 ALT Linux Team",
                developers = {
                    "Alexander \"PaladinDev\" Davydzik <paladindev@altlinux.org>",
                    "Vladimir Vaskov <rirusha@altlinux.org>"
                },
                artists = { "Viktoria \"gingercat\" Zubacheva" },
                translator_credits = _("translator-credits")
            };

            dialog.present(main_window);
        }

        private void open_app_page() {
            new Gtk.UriLauncher("appstream://org.altlinux.Tuner").launch.begin(null, null);
        }

        private void load_extensions() {
            var engine = Peas.Engine.get_default();
            var plugins = new ArrayList<Peas.PluginInfo>();
            for (int i = 0; i < engine.get_n_items(); i++)
                plugins.add((Peas.PluginInfo) engine.get_item(i));

            plugins.sort((a, b) => get_priority(b) - get_priority(a));
            foreach (var plugin in plugins)
                engine.load_plugin(plugin);

            pages = new PageList();
        }

        private int get_priority(Peas.PluginInfo plugin) {
            int priority = 0;

            var priority_str = plugin.get_external_data("Priority");
            if (priority_str != null && int.try_parse(priority_str, out priority)) {
                return priority;
            }

            return 0;
        }

        private void restart_app() {
            string[] env = Environ.get();

            string[] argv = { get_executable_path() };

            try {
                Process.spawn_async(null, argv, env, SpawnFlags.SEARCH_PATH, null, null);
            } catch (Error e) {
                warning(@"Restart failed: $(e.message)");
                return;
            }

            quit();
        }

        private string get_executable_path() {
            try {
                return FileUtils.read_link("/proc/self/exe");
            } catch (FileError e) {}

            return Environment.get_variable("_") ?? Environment.get_prgname();
        }
    }

    public static int main(string[] args) {
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(GETTEXT_PACKAGE);

        if (GLib.File.new_for_path("/.flatpak-info").query_exists()) {
            Peas.Engine.get_default().add_search_path("/app/extensions/lib/tuner/plugins", "/app/extensions/lib/tuner/plugins");
            Environment.set_variable("XDG_DATA_DIRS", Environment.get_variable("XDG_DATA_DIRS") + ":/run/host/usr/share", true);
        }

        return App.instance.run(args);
    }
}
