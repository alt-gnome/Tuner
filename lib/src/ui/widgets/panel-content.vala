namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-content.ui")]
    public class PanelContent : Adw.NavigationPage, Gtk.Buildable {
        [GtkChild]
        private unowned Adw.ToolbarView toolbar_view;
        [GtkChild]
        private unowned Adw.HeaderBar header_bar;

        public unowned Gtk.Widget content { get; set; }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (toolbar_view == null) {
                base.add_child(builder, child, type);
                return;
            }

            if (type == "end") {
                header_bar.pack_end(child as Gtk.Widget);
                return;
            } else if (type == "start") {
                header_bar.pack_start(child as Gtk.Widget);
                return;
            }

            content = child as Gtk.Widget;
        }
    }
}
