using Gee;

namespace Tuner {

    public class App : Adw.Application {
        private const ActionEntry[] APP_ENTRIES = {
            { "about", about_activated },
        };

        private Peas.ExtensionSet page_addins { get; set; }
        private Peas.ExtensionSet content_addins { get; set; }
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
            engine.add_search_path(
                Path.build_filename(LIBDIR, "tuner", "plugins"),
                Path.build_filename(DATADIR, "plugins")
            );
            var user_plugins = Path.build_filename(Environment.get_user_data_dir(), "tuner", "plugins");
            engine.add_search_path(user_plugins, null);

            page_addins = new Peas.ExtensionSet.with_properties(engine, typeof(PageAddin), {}, {});
            content_addins = new Peas.ExtensionSet.with_properties(engine, typeof(ContentAddin), {}, {});

            set_accels_for_action("app.quit", { "<Ctrl>Q" });
            add_action_entries(APP_ENTRIES, this);

            typeof(EmptyPage).ensure();
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
            var dialog = new Adw.AboutDialog() {
                application_name = _("Tuner"),
                application_icon = "org.altlinux.Tuner",
                version = VERSION,
                copyright = "© 2025 ALT Linux Team",
                website = "https://altlinux.space/alt-gnome/Tuner",
                issue_url = "https://altlinux.space/alt-gnome/Tuner/issues",
                developer_name = "ALT Linux Team",
                developers = { "Alexander \"PaladinDev\" Davydzik <paladindev@altlinux.org>" },
                artists = { "Viktoria \"gingercat\" Zubacheva" },
                translator_credits = _("translator-credits"),
                license_type = Gtk.License.GPL_3_0
            };

            dialog.present(active_window);
        }

        private void load_extensions() {
            var engine = Peas.Engine.get_default();
            for (int i = 0; i < engine.get_n_items(); i++) {
                engine.load_plugin(engine.get_item(i) as Peas.PluginInfo);
            }

            // Load page extensions
            for (int i = 0; i < page_addins.get_n_items(); i++) {
                var addin = (PageAddin) page_addins.get_item(i);
                foreach (var page in addin.pages)
                    main_window.add_page(page);
            }

            // Load content extensions
            for (int i = 0; i < content_addins.get_n_items(); i++) {
                var addin = (ContentAddin) content_addins.get_item(i);
                foreach (var content in addin.content_list)
                    main_window.add_content(content);
            }
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
