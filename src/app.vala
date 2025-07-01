using Gee;

namespace Tuner {

    public class App : Adw.Application {
        private const ActionEntry[] APP_ENTRIES = {
            { "open-app-page", open_app_page },
            { "plugin-list", open_plugin_list },
            { "restart", restart_app },
            { "about", about_activated },
            { "quit", quit }
        };

        private Peas.ExtensionSet addins { get; set; }
        private MainWindow main_window;

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
            flags = ApplicationFlags.DEFAULT_FLAGS;
        }

        public override void startup() {
            base.startup();

            settings = new Settings("org.altlinux.Tuner");

            var engine = Peas.Engine.get_default();
            engine.enable_loader("python");

            engine.add_search_path(
                Path.build_filename(LIBDIR, "tuner", "plugins"),
                Path.build_filename(DATADIR, "plugins")
            );
            var user_plugins = Path.build_filename(Environment.get_user_data_dir(), "tuner", "plugins");
            engine.add_search_path(user_plugins, null);

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

            load_extensions();

            main_window.present();
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

            load_extensions_content();
        }

        private int get_priority(Peas.PluginInfo plugin) {
            int priority = 0;

            var priority_str = plugin.get_external_data("Priority");
            if (priority_str != null && int.try_parse(priority_str, out priority)) {
                return priority;
            }

            return 0;
        }

        private void load_extensions_content() {
            var disabled_plugins = settings.get_strv("disabled-plugins");
            var page_list = new ArrayList<PanelPage>();
            var content_list = new ArrayList<PanelPageContent>();

            addins.foreach((s, info, obj) => {
                var addin = obj as Addin;

                if (!(info.module_name in disabled_plugins)) {
                    addin.activate();

                    page_list.add_all(addin.get_page_list());
                    content_list.add_all(addin.get_content_list());
                }
            });

            foreach (var page in page_list)
                main_window.add_page(page);

            foreach (var content in content_list)
                main_window.add_content(content);

            main_window.open_last();

            if (page_list.is_empty && addins.get_n_items() > 0)
                main_window.show_all_disabled();
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
