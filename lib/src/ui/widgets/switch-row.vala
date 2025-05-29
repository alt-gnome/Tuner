namespace Tuner {

    /**
     * {@link ActionRow} with switch widget that bind with settings boolean value
     */
    [GtkTemplate (ui = "/org/altlinux/Tuner/switch-row.ui")]
    internal class SwitchRow : Adw.ActionRow {
        private unowned Binding binding;

        [GtkChild]
        private unowned ResetButton reset_button;

        public bool active { get; set; }

        public void setup(Binding binding) {
            this.binding = binding;

            if (binding.has_default) {
                reset_button.visible = true;
                binding.bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
            }
        }

        [GtkCallback]
        private void on_reset() {
            binding.reset();
        }
    }
}
