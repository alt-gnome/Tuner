using Gee;

namespace Tuner {

    /**
     * {@link SwitchRow} that adds or removes {@link FlagsSwitchRow.value} from setting string array
     */
    public class FlagsSwitchRow : SwitchRow, Modifier {
        public string value { get; set; }

        construct {
            reset_button.visible = false;
        }

        public override void key_found() {
            var schema_key = schema.get_key(key);
            Variant key_range;
            schema_key.get_range().get("(sv)", null, out key_range);
            if (!(@value in key_range.get_strv())) {
                is_valid_setting = false;
                warning(@"Value \"$value\" does not exists. Skipping");
                return;
            }
            notify["active"].connect(update_active);

            settings.changed[key].connect(settings_changed);
            settings_changed();

            setup_separator_revealer(revealer, reset_button);
        }

        public void update_active() {
            var flags = new ArrayList<string>.wrap(settings.get_strv(key));

            if (@value in flags) flags.remove(@value);

            if (active)
                flags.add(@value);

            settings.set_strv(key, flags.to_array().copy());
        }

        public void settings_changed() {
            active = @value in settings.get_strv(key);
        }
    }
}
