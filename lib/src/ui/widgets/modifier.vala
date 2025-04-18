namespace Tuner {

    public interface Modifier : Object {
        public abstract Settings? settings { get; set; }
        public abstract SettingsSchema? schema { get; set; }
        public abstract string? schema_id { get; set; }
        public abstract string? key { get; set; }

        public abstract bool is_valid_setting { get; set; default = false; }
        public abstract bool is_default { get; set; }

        public virtual void key_found() {}

        public virtual void setup() {
            if (this is Gtk.Widget)
                bind_property("is-valid-setting", this, "sensitive");

            notify["key"].connect(update_valid_status);
        }

        public virtual void update_valid_status(ParamSpec spec) {
            is_valid_setting = validate_setting();

            if (is_valid_setting) key_found();
        }
        
        private bool validate_setting() {
            var store = SettingsStore.instance;

            if (store.settings[schema_id] != null) {
                settings = store.settings[schema_id].settings;
                schema = store.settings[schema_id].schema;

                return has_key();
            }

            foreach (var source in store.sources) {
                schema = source.lookup(schema_id, true);
                if (schema != null) {
                    break;
                }
            }

            if (schema == null) {
                store.settings[schema_id] = new SettingsSource();

                warning(@"Schema id \"$schema_id\" does not exists. Skipping");

                return false;
            }

            settings = new Settings(schema_id);
            store.settings[schema_id] = new SettingsSource() {
                settings = settings,
                schema = schema
            };

            return has_key();
        }

        public virtual bool has_key() {
            return key != null && schema != null && schema.has_key(key);
        }
    }
}
