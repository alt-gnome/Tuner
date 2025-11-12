namespace Tuner {

    public class Expander : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public bool show_enable_switch { get; set; }

        public override Gtk.Widget? create() {
            var row = new Adw.ExpanderRow() {
                show_enable_switch = show_enable_switch,
                title = title,
                subtitle = subtitle
            };

            if (binding != null)
                binding.bind(row, "enable-expansion");

            foreach (var child in childs) {
                var widget = child as Widget;

                if (widget != null) {
                    var widget_content = widget.native_widget;

                    if (widget_content != null)
                        row.add_row(widget_content);
                }
            }

            return row;
        }

        public override bool accepts(Item item, string? type) {
            return item is Widget;
        }
    }
}
