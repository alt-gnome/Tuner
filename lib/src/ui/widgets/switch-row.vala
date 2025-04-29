namespace Tuner {

    /**
     * {@link ActionRow} with switch widget that bind with settings boolean value
     */
    [GtkTemplate (ui = "/org/altlinux/Tuner/switch-row.ui")]
    public class SwitchRow : ActionRow, Modifier {
        [GtkChild]
        public unowned Gtk.Revealer revealer;
        [GtkChild]
        public unowned ResetButton reset_button;

        public bool active { get; set; }

        public override void key_found() {
            settings.bind(key, this, "active", SettingsBindFlags.DEFAULT);
            bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE);
            update_default();
            notify["active"].connect(update_default);

            setup_separator_revealer(revealer, reset_button);
        }

        private void update_default() {
            is_default = !settings.get_default_value(key).equal(settings.get_value(key));
        }

        [GtkCallback]
        private void on_reset() {
            settings.reset(key);
        }
    }
}
