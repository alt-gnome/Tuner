using Gee;

namespace Tuner {

    public class App : Adw.Application {
        private const ActionEntry[] APP_ENTRIES = {
            { "about", about_activated },
            { "open-app-page", open_app_page },
            { "quit", quit },
        };

        private Peas.ExtensionSet addins { get; set; }
        private Adw.ApplicationWindow window;

        private static App _instance;
        public static App instance {
            get {
                if (_instance == null)
                    _instance = new App();

                return _instance;
            }
        }

        public App () {
            Object (
                application_id: ID,
                flags: ApplicationFlags.DEFAULT_FLAGS
            );
        }

        construct {
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
            if (window != null) {
                window.present();
                return;
            }

            var engine = Peas.Engine.get_default();
            for (int i = 0; i < engine.get_n_items(); i++) {
                engine.load_plugin(engine.get_item(i) as Peas.PluginInfo);
            }

            if (addins.get_n_items() == 0) {
                window = new NoPluginsWindow(this);
            } else {
                window = new MainWindow(this);
            }

            if (addins.get_n_items() != 0) {
                load_extensions();
            }

            window.present();
        }

        private void about_activated() {
            var dialog = new Adw.AboutDialog.from_appdata("org/altlinux/Tuner/org.altlinux.Tuner.metainfo.xml", VERSION) {
                application_icon = "org.altlinux.Tuner",
                copyright = "© 2025 ALT Linux Team",
                developers = {
                    "Alexander \"PaladinDev\" Davydzik <paladindev@altlinux.org>",
                    "Vladimir Vaskov <rirusha@altlinux.org>"
                },
                artists = { "Viktoria \"gingercat\" Zubacheva" },
                translator_credits = _("translator-credits"),
            };

            dialog.add_credit_section("Loaded plugins", get_loaded_plugins());

            dialog.present(active_window);
        }

        private void open_app_page() {
            new Gtk.UriLauncher("appstream://org.altlinux.Tuner").launch.begin(null, null);
        }

        private void load_extensions() {
            var page_list = new ArrayList<PanelPage>();
            var content_list = new ArrayList<PanelPageContent>();

            for (int i = 0; i < addins.get_n_items(); i++) {
                var addin = (Addin) addins.get_item(i);
                addin.activate();
                check_and_merge(addin.get_type().name(), page_list, addin.get_page_list());
                content_list.add_all(addin.get_content_list());
            }

            page_list.sort((a, b) => a.priority - b.priority);

            var main_window = window as MainWindow;

            if (main_window == null) {
                return;
            }

            foreach (var page in page_list)
                main_window.add_page(page);

            foreach (var content in content_list)
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

        private void check_and_merge(string type_name, ArrayList<PanelPage> list1, ArrayList<PanelPage> list2) {
            foreach (var page in list2) {
                if (page.tag != null && list1.first_match(it => it.tag == page.tag) != null) {
                    message(@"Page with tag \"$(page.tag)\" from $type_name already exists, skipped.");
                    continue;
                }
                list1.add(page);
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
