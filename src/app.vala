using Gee;

namespace Tuner {

    public class App : Adw.Application {
        private const ActionEntry[] APP_ENTRIES = {
            { "reload-extensions", reload_extensions },
            { "open-app-page", open_app_page },
            { "about", about_activated },
            { "quit", quit }
        };

        private Peas.ExtensionSet addins { get; set; }
        private MainWindow main_window;

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

            var engine = Peas.Engine.get_default();
            engine.enable_loader("python");

            engine.add_search_path(
                Path.build_filename(LIBDIR, "tuner", "plugins"),
                Path.build_filename(DATADIR, "plugins")
            );
            var user_plugins = Path.build_filename(Environment.get_user_data_dir(), "tuner", "plugins");
            engine.add_search_path(user_plugins, null);

            addins = new Peas.ExtensionSet.with_properties(engine, typeof(Addin), {}, {});
            addins.extension_added.connect((info, obj) => load_extension(info, obj as Addin));

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

            dialog.add_credit_section(_("Loaded plugins"), get_loaded_plugins());

            dialog.present(active_window);
        }

        private void open_app_page() {
            new Gtk.UriLauncher("appstream://org.altlinux.Tuner").launch.begin(null, null);
        }

        private void load_extensions() {
            var engine = Peas.Engine.get_default();
            for (int i = 0; i < engine.get_n_items(); i++)
                engine.load_plugin(engine.get_item(i) as Peas.PluginInfo);
        }

        private void reload_extensions() {
            var loaded = false;
            var engine = Peas.Engine.get_default();
            engine.rescan_plugins();

            for (int i = 0; i < engine.get_n_items(); i++) {
                var info = engine.get_item(i) as Peas.PluginInfo;
                if (!info.loaded) {
                    loaded = true;

                    engine.load_plugin(info);
                }
            }

            if (!loaded)
                main_window.toast(_("No new plugins found!"));
        }

        private void load_extension(Peas.PluginInfo info, Addin addin) {
            addin.activate();

            foreach (var page in addin.get_page_list()) {
                if (!main_window.add_page(page))
                    warning(@"Page with tag \"$(page.tag)\" from $(info.name) plugin already exists, skipped.");
            }

            foreach (var content in addin.get_content_list())
                main_window.add_content(content);
        }

        private string[] get_loaded_plugins() {
            string[] result = {};
            for (int i = 0; i < addins.get_n_items(); i++) {
                var addin = (Addin) addins.get_item(i);
                if (addin.plugin_info?.name != null)
                    result += addin.plugin_info.name;
            }

            return result.copy();
        }
    }

    public static int main(string[] args) {
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(GETTEXT_PACKAGE);

        return App.instance.run(args);
    }
}
