namespace Tuner {

    /**
     * Entry row with file selector button.
     */
    public class File : Widget {
        public string title { get; set; }
        public bool select_folder { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new Adw.EntryRow() {
                    title = title
                };

                var file_button = new Gtk.Button.from_icon_name("folder-symbolic") {
                    css_classes = { "flat" },
                    valign = Gtk.Align.CENTER
                };
                file_button.clicked.connect(() => file_button_clicked.begin(row));

                var reset_button = new ResetButton() {
                    visible = false,
                    revealer = Gtk.Align.END
                };
                reset_button.reset.connect(binding.reset);
                if (binding.has_default)
                    binding.bind_property("is-default", reset_button, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

                var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
                box.append(reset_button);
                box.append(file_button);

                row.add_suffix(box);

                binding.bind(row, "text");
                return row;
            }
            return null;
        }

        private async void file_button_clicked(Adw.EntryRow row) {
            var dialog = new Gtk.FileDialog();
            try {
                GLib.File? file;

                if (select_folder)
                    file = yield dialog.select_folder(get_window(row), null);
                else
                    file = yield dialog.open(get_window(row), null);

                if (file != null)
                    row.text = @"file://$(file.get_path())";
            } catch (Error _) {}
        }

        private Gtk.Window? get_window(Gtk.Widget widget) {
            return widget.get_root() as Gtk.Window;
        }
    }
}
