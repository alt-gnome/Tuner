namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-content.ui")]
    public class PanelContent : Adw.NavigationPage, Gtk.Buildable {
        [GtkChild]
        private unowned Adw.ToolbarView toolbar_view;
        [GtkChild]
        private unowned Adw.HeaderBar header_bar;

        public Gtk.Widget content { get; set; }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
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

            content = child as Gtk.Widget;
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
    }
}
