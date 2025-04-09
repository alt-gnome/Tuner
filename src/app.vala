namespace Tuner {

    internal class App : Adw.Application {
        private Peas.ExtensionSet page_addins { get; set; }
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
            application_id = Build.ID;
            flags = ApplicationFlags.DEFAULT_FLAGS;
        }

        public override void activate() {
            if (main_window != null) {
                main_window.present();
                return;
            }

            main_window = new MainWindow(this);

            var engine = Peas.Engine.get_default();
            engine.add_search_path(
                Path.build_filename(Build.LIBDIR, "tuner", "plugins"),
                Path.build_filename(Build.DATADIR, "plugins")
            );
            var user_plugins = Path.build_filename(Environment.get_user_data_dir(), "tuner", "plugins");
            message(user_plugins);
            engine.add_search_path(user_plugins, null);

            page_addins = new Peas.ExtensionSet.with_properties(engine, typeof(PageAddin), {}, {});
            page_addins.extension_added.connect((info, extension) => {
                var addin = (PageAddin) extension;
                foreach (var page in addin.pages)
                    main_window.add_page(page);
            });

            for (int i = 0; i < engine.get_n_items(); i++) {
                engine.load_plugin(engine.get_item(i) as Peas.PluginInfo);
            }

            main_window.present();
        }
    }

    public static int run(string[] args) {
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(Build.GETTEXT_PACKAGE, Build.LOCALEDIR);
        Intl.bind_textdomain_codeset(Build.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(Build.GETTEXT_PACKAGE);

        return App.instance.run(args);
    }
}
