namespace Tuner {

    /**
     * {@link SwitchRow} that will set value to settings if active and reset setting value otherwise
     */
    public class ValueSwitchRow : SwitchRow, Modifier {
        public string value { get; set; }

        public override void key_found() {
            bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE);
            notify["active"].connect(update_active);

            settings.changed[key].connect(setting_changed);
            setting_changed();

            setup_separator_revealer(revealer, reset_button);
        }

        private void update_active() {
            if (active)
                settings.set_string(key, @value);
            else
                settings.reset(key);
        }

        private void setting_changed() {
            is_default = active = settings.get_string(key) == value;
        }
    }
}
