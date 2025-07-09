namespace Tuner {

    // FIXME: memory leak
    // also leaks just `new PanelList()` without anything done with it
    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-list.ui")]
    public class PanelList : Adw.NavigationPage, Gtk.Buildable {
        private unowned ListModel? _model;

        [GtkChild]
        private unowned Adw.ToolbarView toolbar_view;
        [GtkChild]
        private unowned Adw.HeaderBar header_bar;
        [GtkChild]
        private unowned Gtk.ListBox list_box;
        [GtkChild]
        protected unowned Gtk.Stack stack;

        public unowned ListModel? model {
            get { return _model; }
            set {
                if (value == null) {
                    list_box.bind_model(null, null);
                    return;
                }

                if (value.get_item_type().is_a(typeof(Page))) {
                    _model = value;
                    list_box.bind_model(_model, create_row);
                }
            }
        }

        construct {
            list_box.set_header_func(update_header);
        }

        public PanelList(Page? page = null) {
            if (page != null) {
                title = page.title;
                model = page.subpages_model;

                if (page.title_widget != null)
                    header_bar.title_widget = page.title_widget;

                if (page.start_widgets != null)
                    foreach (var widget in page.start_widgets)
                        header_bar.pack_start(widget);

                if (page.end_widgets != null)
                    foreach (var widget in page.end_widgets)
                        header_bar.pack_end(widget);

                if (page.top_widgets != null)
                    foreach (var widget in page.top_widgets)
                        toolbar_view.add_top_bar(widget);

                if (page.bottom_widgets != null)
                    foreach (var widget in page.bottom_widgets)
                        toolbar_view.add_bottom_bar(widget);
            }
        }

        public bool activate_index(int index) {
            var row = list_box.get_row_at_index(index);

            if (row == null)
                return false;

            row.activate();

            return true;
        }

        public void pack_start(Gtk.Widget child) {
            header_bar.pack_start(child);
        }

        public void pack_end(Gtk.Widget child) {
            header_bar.pack_end(child);
        }

        /**
         * Adds a bottom bar to toolbar view
         */
        public void add_top_bar(Gtk.Widget widget) {
            toolbar_view.add_top_bar(widget);
        }

        /**
         * Adds a bottom bar to toolbar view
         */
        public void add_bottom_bar(Gtk.Widget widget) {
            toolbar_view.add_bottom_bar(widget);
        }

        private void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (toolbar_view == null) {
                base.add_child(builder, child, type);
                return;
            }

            if (type == "end") {
                pack_end(child as Gtk.Widget);
                return;
            } else if (type == "start") {
                pack_start(child as Gtk.Widget);
                return;
            } else if (type == "top") {
                add_top_bar(child as Gtk.Widget);
                return;
            } else if (type == "bottom") {
                add_bottom_bar(child as Gtk.Widget);
                return;
            }
        }

        private Gtk.Widget create_row(Object obj) {
            var page = (Page) obj;
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
