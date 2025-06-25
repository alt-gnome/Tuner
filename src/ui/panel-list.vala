namespace Tuner {

    // FIXME: memory leak
    // also leaks just `new PanelList()` without anything done with it
    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-list.ui")]
    public class PanelList : PanelContent {
        private unowned ListModel? _model;

        [GtkChild]
        private unowned Gtk.ListBox list_box;

        public unowned ListModel? model {
            get { return _model; }
            set {
                if (value == null) {
                    list_box.bind_model(null, null);
                    return;
                }

                if (value.get_item_type().is_a(typeof(PanelPage))) {
                    _model = value;
                    list_box.bind_model(_model, create_row);
                }
            }
        }

        construct {
            list_box.set_header_func(update_header);
        }

        public void activate_index(int index) {
            var row = list_box.get_row_at_index(index);
            list_box.select_row(row);
            list_box.row_activated(row);
        }

        private Gtk.Widget create_row(Object obj) {
            var page = (PanelPage) obj;
            var row = new PanelListRow(page);

            return row;
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
            if (before != null) {
                var panel_row = (PanelListRow) row;
                var panel_row_before = (PanelListRow) before;

                if (panel_row.page.category != panel_row_before.page.category) {
                    row.set_header(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
                    return;
                }
            }

            row.set_header(null);
        }

        [GtkCallback]
        private void activated(Object obj) {
            row_activated(obj as PanelListRow);
        }

        public signal void row_activated(PanelListRow row);
    }
}
