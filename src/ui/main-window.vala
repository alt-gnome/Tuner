namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/main-window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;
        [GtkChild]
        private unowned Adw.NavigationView nav;
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned Gtk.Stack stack;

        public ListStore model {
            get; set; default = new ListStore(typeof(PanelPage));
        }

        public MainWindow(Gtk.Application app) {
            Object(application: app);

            Tuner.init(
                (page, show) => {
                    set_page(page, show);
                    return true;
                },
                (page) => {
                    nav.push(page);
                    return true;
                }
            );
        }

        public bool add_page(PanelPage page) {
            if (page.tag != null && find_page(page.tag) != null) {
                return false;
            }

            model.insert_sorted(page, (a, b) => ((PanelPage) a).priority - ((PanelPage) b).priority);

            if (model.n_items == 1) {
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
            if (model.find_with_equal_func_full(null, item => {
                var page = (PanelPage) item;

                return page.tag == tag;
            }, out pos)) {
                return model.get_item(pos) as PanelPage;
            }
            return null;
        }

        public void toast(string title) {
            toast_overlay.add_toast(new Adw.Toast(title) {
                timeout = 3
            });
        }

        private void set_page(Adw.NavigationPage? page, bool show = true) {
            split_view.content = page;

            if (show)
                split_view.show_content = true;
        }

        [GtkCallback]
        private void row_activated(PanelListRow row) {
            if (row.page.layout_type == LayoutType.SUBPAGES) {
                var list = new PanelList() {
                    title = row.page.title,
                    model = row.page.model
                };
                list.row_activated.connect(row_activated);
                nav.push(list);
                for (int i = 0; i < row.page.model.n_items; i++) {
                    var page = (PanelPage) row.page.model.get_item(i);
                    if (page.layout_type == LayoutType.INTERNAL) {
                        set_page(page, false);
                        break;
                    }
                }
                return;
            } else if (row.page.layout_type == LayoutType.CUSTOM) {
                nav.push(row.page.custom_content);
            }

            set_page(row.page);
        }
    }
}
