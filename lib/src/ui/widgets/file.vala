namespace Tuner {

    public class File : Widget {
        public string title { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new Adw.EntryRow() {
                    title = title
                };

                row.add_suffix(new Gtk.Button.from_icon_name("folder-symbolic") {
                    css_classes = { "flat" },
                    valign = Gtk.Align.CENTER
                });

                binding.bind(row, "text");
                return row;
            }
            return null;
        }
    }
}
