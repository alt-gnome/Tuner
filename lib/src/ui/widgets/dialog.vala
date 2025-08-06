namespace Tuner {

    public class Dialog : Widget, Gtk.Buildable {
        private Page page_cache;
        private Adw.Dialog cache;

        public string title { get; set; }
        public string subtitle { get; set; }
        public string? dialog_title { get; set; }
        public string? icon_name { get; set; }
        public int content_height { get; set; default = -1; }
        public int content_width { get; set; default = -1; }
        public bool follows_content_size { get; set; }
        public bool show_arrow { get; set; default = true; }

        construct {
            page_cache = new Page();
        }

        public Dialog() {}

        public Dialog.with_page(Page page) {
            page_cache = page;
        }

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

        public override bool accepts(Item item, string? type) {
            return page_cache.accepts(item, type);
        }

        private void add_child(Gtk.Builder builder, Object child, string? type) {
            page_cache.add_child(builder, child, type);
        }

        private void navigate(Object obj) {
            var row = (Adw.ActionRow) obj;

            if (cache == null) {
                page_cache.title = dialog_title ?? title;
                var panel = new Panel.with_page(page_cache);

                cache = new Adw.Dialog() {
                    follows_content_size = follows_content_size,
                    content_height = content_height,
                    content_width = content_width,
                    child = panel
                };

                if (page_cache.breakpoints != null)
                    foreach (var breakpoint in page_cache.breakpoints)
                        cache.add_breakpoint(breakpoint);
            }

            cache.present(row);
        }
    }
}
