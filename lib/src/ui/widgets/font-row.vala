namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/font-row.ui")]
    internal class FontRow : Adw.ActionRow {
        private unowned Binding binding;
        private string _font;

        [GtkChild]
        private unowned ResetButton reset_button;

        public string font {
            get { return _font; }
            set {
                _font = value;
                var font_description = Pango.FontDescription.from_string(font);
                subtitle = @"<span face='$(font_description.get_family())'>$font</span>";
            }
        }

        [GtkCallback]
        private void row_activated() {
            select_font.begin();
        }

        public void setup(Binding binding) {
            this.binding = binding;

            if (binding.has_default)
                binding.bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
        }

        [GtkCallback]
        private void on_reset() {
            binding.reset();
        }

        private async void select_font() {
            var font_description = Pango.FontDescription.from_string(font);

            var dialog = new Gtk.FontDialog();

            try {
                var font = yield dialog.choose_font(get_root() as Gtk.Window, font_description, null);
                this.font = font.to_string();
            } catch (Error err) {}
        }
    }
}
