using Gee;

namespace Tuner {

    internal class SettingsStore : Object {
        private static SettingsStore _instance;
        public static SettingsStore instance {
            get {
                if (_instance == null)
                    _instance = new SettingsStore();

                return _instance;
            }
        }
        public ArrayList<SettingsSchemaSource> sources;
        public TreeMap<string, SettingsSource> settings;

        construct {
            settings = new TreeMap<string, SettingsSource>();
            sources = new ArrayList<SettingsSchemaSource>();

            foreach (var data_dir in Environment.get_system_data_dirs()) {
                try {
                    var source = new SettingsSchemaSource.from_directory(
                        Path.build_filename(data_dir, "glib-2.0", "schemas"),
                        null, true
                    );
                    sources.add(source);
                } catch (Error err) {}
            }
        }
    }
}
