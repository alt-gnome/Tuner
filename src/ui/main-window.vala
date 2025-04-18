namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/main-window.ui")]
    public class MainWindow : Adw.ApplicationWindow {
        [GtkChild]
        private unowned Adw.NavigationSplitView split_view;
        [GtkChild]
        private unowned Gtk.ListBox panels_list_box;
        private ListStore panels_list;
        
        public MainWindow(Gtk.Application app) {
            Object(application: app);

            panels_list = new ListStore(typeof(PanelPage));
            panels_list_box.bind_model(panels_list, create_row);

            panels_list_box.set_header_func(update_header);
        }

        public void add_page(PanelPage page) {
            panels_list.append(page);

            if (panels_list.n_items == 1)
                split_view.content = page;
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
        }
    }
}
