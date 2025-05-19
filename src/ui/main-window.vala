namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/main-window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        private ListStore panels_list;

        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned Gtk.ListBox panels_list_box;
        [GtkChild]
        private unowned Gtk.Stack stack;

        public MainWindow(Gtk.Application app) {
            Object(application: app);

            panels_list = new ListStore(typeof(PanelPage));
            panels_list_box.bind_model(panels_list, create_row);

            panels_list_box.set_header_func(update_header);
        }

        public bool add_page(PanelPage page) {
            if (page.tag != null && find_page(page.tag) != null) {
                return false;
            }

            panels_list.insert_sorted(page, (a, b) => ((PanelPage) a).priority - ((PanelPage) b).priority);

            if (panels_list.n_items == 1) {
                stack.visible_child_name = "content";
                split_view.content = page;
            }

            return true;
        }

        public void add_content(PanelPageContent content) {
            var page = find_page(content.tag);

            if (page != null) {
                page.add_content(content);
                return;
            }
            warning(@"PanelPage with tag \"$(content.tag)\" not found. Content skipped.");
        }

        public PanelPage? find_page(string tag) {
            uint pos;
            if (panels_list.find_with_equal_func_full(null, item => {
                var page = (PanelPage) item;

                return page.tag == tag;
            }, out pos)) {
                return panels_list.get_item(pos) as PanelPage;
            }
            return null;
        }

        public void toast(string title) {
            toast_overlay.add_toast(new Adw.Toast(title) {
                timeout = 3
            });
        }

        private Gtk.Widget create_row(Object obj) {
            var page = (PanelPage) obj;
            var row = new PanelRow(page);

            return row;
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
            if (before != null) {
                var panel_row = (PanelRow) row;
                var panel_row_before = (PanelRow) before;

                if (panel_row.page.category != panel_row_before.page.category) {
                    row.set_header(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
                    return;
                }
            }

            row.set_header(null);
        }

        [GtkCallback]
        private void set_page(Object obj) {
            var row = (PanelRow) obj;

            split_view.content = row.page;
            split_view.show_content = true;
        }
    }
}
