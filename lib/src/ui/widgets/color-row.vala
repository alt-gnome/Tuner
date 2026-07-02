namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/color-row.ui")]
    internal class ColorRow : Adw.ActionRow {
        private string _color = "rgb(0,0,0)";
        private unowned Binding binding;

        public string color {
            get { return _color; }
            set {
                var rgba = Gdk.RGBA();

                if (rgba.parse(value)) {
                    _color = rgba.to_string();
                    indicator.rgba = rgba;
                }
            }
        }

        [GtkChild]
        private unowned ResetButton reset_button;
        [GtkChild]
        private unowned ColorIndicator indicator;

        public void setup(Binding binding) {
            this.binding = binding;

            if (binding.has_default)
                binding.bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
        }

        [GtkCallback]
        private void row_activated() {
            select_color.begin();
        }

        [GtkCallback]
        private void on_reset() {
            binding.reset();
        }

        private async void select_color() {
            var dialog = new Gtk.ColorDialog();

            try {
                var color = yield dialog.choose_rgba(get_root() as Gtk.Window, indicator.rgba, null);
                this.color = color.to_string();
            } catch (Error err) {}
        }
    }
}
