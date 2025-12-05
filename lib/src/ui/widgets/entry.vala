namespace Tuner {

    public class Entry : Widget {
        public string title { get; set; }
        public bool show_apply_button { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new Adw.EntryRow() {
                    title = title,
                    show_apply_button = show_apply_button
                };

                var reset_button = new ResetButton() {
                    visible = false,
                    revealer = Gtk.Align.END
                };
                reset_button.reset.connect(binding.reset);
                if (binding.has_default)
                    binding.bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

                if (show_apply_button) {
                    row.apply.connect(() => {
                        binding.set_value(row.text);
                    });

                    binding.changed.connect(() => {
                        var value = Value(Type.STRING);
                        if (binding.get_value(ref value)) {
                            if (value.holds(Type.STRING) && value.get_string() != row.text)
                                row.text = value.get_string();
                        }
                    });

                    binding.emit_changed();
                } else {
                    binding.bind(row, "text");
                }

                return row;
            }
            return null;
        }
    }
}
