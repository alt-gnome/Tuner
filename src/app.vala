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
        private TreeMap<Peas.PluginInfo, Addin> loaded_plugins { get; set; }
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

            loaded_plugins = new TreeMap<Peas.PluginInfo, Addin>();
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

            dialog.add_credit_section(_("Loaded plugins"), get_loaded_plugins_info());

            dialog.present(active_window);
        }

        private string[] get_loaded_plugins_info() {
            string[] result = {};

            foreach (var entry in loaded_plugins) {
                var info = entry.key.name;

                if (entry.key.authors.length > 0) {
                    var authors = entry.key.authors;
                    info += @" by $(authors[0])";

                    for (int i = 1; i < authors.length; i++)
                        info += @", $(authors[i])";
                }

                if (entry.key.website != null)
                    info += @" $(entry.key.website)";

                result += info;
            }

            return result;
        }

        private void open_app_page() {
            new Gtk.UriLauncher("appstream://org.altlinux.Tuner").launch.begin(null, null);
        }

        private void load_extensions() {
            var engine = Peas.Engine.get_default();
            for (int i = 0; i < engine.get_n_items(); i++)
                engine.load_plugin(engine.get_item(i) as Peas.PluginInfo);

            load_extensions_content();
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
            else
                load_extensions_content();
        }

        private void load_extensions_content() {
            var page_list = new ArrayList<PanelPage>();
            var content_list = new ArrayList<PanelPageContent>();

            addins.foreach((s, info, obj) => {
                var addin = obj as Addin;

                if (!loaded_plugins.has_key(info)) {
                    addin.activate();

                    page_list.add_all(addin.get_page_list());
                    content_list.add_all(addin.get_content_list());

                    loaded_plugins[info] = addin;
                }
            });

            foreach (var page in page_list)
                main_window.add_page(page);

            foreach (var content in content_list)
                main_window.add_content(content);
        }
    }

    public static int main(string[] args) {
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(GETTEXT_PACKAGE);

        if (File.new_for_path("/.flatpak-info").query_exists()) {
            Peas.Engine.get_default().add_search_path("/app/extensions/lib/tuner/plugins", "/app/extensions/lib/tuner/plugins");
            Environment.set_variable("XDG_DATA_DIRS", Environment.get_variable("XDG_DATA_DIRS") + ":/run/host/usr/share", true);
        }

        return App.instance.run(args);
    }
}
