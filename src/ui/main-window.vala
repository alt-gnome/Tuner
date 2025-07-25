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
        private unowned Gtk.Button action_button;
        [GtkChild]
        private unowned Gtk.Stack stack;
        [GtkChild]
        private unowned SearchablePanelList panel_list;
        [GtkChild]
        private unowned Adw.BreakpointBin breakpoint_bin;

        public ListStore model {
            get; set; default = new ListStore(typeof(Page));
        }

        public MainWindow(Gtk.Application app) {
            Object(application: app);

            Tuner.init(
                text => {
                    toast(text);
                    return true;
                },
                (page, show) => {
                    set_page(page, show);
                    return true;
                },
                page => {
                    nav.push(page);
                    return true;
                }
            );
        }

        public bool add_page(Page page) {
            model.insert_sorted(page, (a, b) => ((Page) a).priority - ((Page) b).priority);

            if (page.breakpoints != null)
                foreach (var breakpoint in page.breakpoints)
                    breakpoint_bin.add_breakpoint(breakpoint);

            stack.visible_child_name = "content";

            return true;
        }

        public void open_last() {
            var tag = App.settings.get_string("last-page");

            if (tag != "") {
                for (int i = 0; i < model.n_items; i++) {
                    var page = (Page) model.get_item(i);
                    if (page.tag == tag) {
                        panel_list.activate_index(i);
                        return;
                    }
                }
            }

            panel_list.activate_index(0);
        }

        public void show_all_disabled() {
            action_button.label = _("Plugins list");
            action_button.action_name = "app.plugin-list";
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
        private void update_search(string? text) {
            if (text != null) {
                panel_list.clear();
                for (int i = 0; i < model.n_items; i++) {
                    var page = (Page) model.get_item(i);
                    if (page.title.down().contains(text.down())) {
                        panel_list.search_model.append(page);
                    }
                }
            }
        }

        [GtkCallback]
        private void search_result_activated(Page result) {
            for (int i = 0; i < model.n_items; i++) {
                var page = (Page) model.get_item(i);
                if (page == result) {
                    panel_list.activate_index(i);
                    break;
                }
            }
        }

        [GtkCallback]
        private void row_activated(PanelListRow row) {
            if (row.page.has_subpages) {
                if (row.cached_list == null) {
                    var list = new PanelList(row.page);
                    list.row_activated.connect(row_activated);
                    row.cached_list = list;
                }
                nav.push(row.cached_list);

                for (int i = 0; i < row.page.subpages_model.n_items; i++) {
                    var page = (Page) row.page.subpages_model.get_item(i);
                    if (!page.has_subpages && page.custom_content == null) {
                        row.cached_list.activate_index(i);
                        break;
                    }
                }
                return;
            } else if (row.page.custom_content != null) {
                nav.push(row.page.custom_content);
            }

            App.settings.set_string("last-page", row.page.tag ?? "");
            set_page(row.panel);
        }
    }
}
