using Gee;

namespace Tuner {

    public class ComboRow : Adw.ComboRow, Modifier {
        public ArrayList<string> original;

        public Settings? settings { get; set; }
        public SettingsSchema? schema { get; set; }
        public string? schema_id { get; set; }
        public string? key { get; set; }

        public bool is_valid_setting { get; set; }
        public bool is_default { get; set; }

        construct {
            setup();
        }

        public void update_is_default() {
            is_default = settings.get_default_value(key).get_string() != settings.get_string(key);
        }

        public void on_reset() {
            settings.reset(key);
            set_selected(original.index_of(settings.get_string(key)));
            update_is_default();
        }

        public void on_selected() {
            var row_string = original[(int) selected];

            settings.set_string(key, row_string);
            update_is_default();
        }
    }
}
