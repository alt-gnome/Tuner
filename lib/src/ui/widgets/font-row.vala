namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/font-row.ui")]
    public class FontRow : ActionRow, Modifier {
        [GtkChild]
        private unowned Gtk.Revealer revealer;
        [GtkChild]
        private unowned ResetButton reset_button;

        private void update_label() {
            var font_string = settings.get_string(key);
            var default_font_string = settings.get_default_value(key).get_string();

            is_default = font_string != default_font_string;

            var font_description = Pango.FontDescription.from_string(font_string);
            subtitle = @"<span face='$(font_description.get_family())'>$font_string</span>";
        }

        public override void key_found() {
            update_label();
            bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE);

            setup_separator_revealer(revealer, reset_button);
        }

        [GtkCallback]
        private void row_activated() {
            select_font.begin();
        }

        [GtkCallback]
        private void on_reset() {
            settings.reset(key);
            update_label();
        }

        private async void select_font() {
            var font_description = Pango.FontDescription.from_string(settings.get_string(key));

            var dialog = new Gtk.FontDialog();

            try {
                var font = yield dialog.choose_font(get_root() as Gtk.Window, font_description, null);
                settings.set_string(key, font.to_string());
                update_label();
            } catch (Error err) {}
        }
    }
}
