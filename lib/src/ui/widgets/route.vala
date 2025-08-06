namespace Tuner {

    public class Route : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public string? icon_name { get; set; }
        public string tag { get; set; }
        public bool show_arrow { get; set; default = true; }

        public override Gtk.Widget? create() {
            var row = new Adw.ActionRow() {
                title = title,
                subtitle = subtitle,
                activatable = true
            };
            row.activated.connect(navigate);

            if (show_arrow)
                row.add_suffix(new Gtk.Image() {
                    icon_name = "go-next-symbolic"
                });

            if (icon_name != null)
                row.add_prefix(new Gtk.Image() {
                    icon_name = icon_name
                });

            return row;
        }

        private void navigate(Object obj) {
            var row = (Adw.ActionRow) obj;
            row.activate_action("navigation.push", "s", tag);
        }
    }
}
