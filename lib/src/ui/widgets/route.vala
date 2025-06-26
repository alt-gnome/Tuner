namespace Tuner {

    public class Route : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public string? icon_name { get; set; }
        public string tag { get; set; }

        public override Gtk.Widget? create() {
            var row = new Adw.ActionRow() {
                title = title,
                subtitle = subtitle,
                activatable = true
            };
            row.activated.connect(navigate);
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

            var parent = row.get_parent();

            while (parent != null) {
                var nav = parent as Adw.NavigationView;
                if (nav != null) {
                    nav.push_by_tag(tag);
                    break;
                }
                parent = parent.get_parent();
            }
        }
    }
}
