namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-page.ui")]
    public class PanelPage : Adw.NavigationPage, Gtk.Buildable {
        [GtkChild]
        private unowned Adw.NavigationView main_nav_view;
        [GtkChild]
        private unowned Adw.ToolbarView main_toolbar_view;

        public string icon_name { get; set; }
        public string category { get; set; }
        public int priority { get; set; }

        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (main_nav_view == null) {
                base.add_child(builder, child, type);
                return;
            }

            if (child is Gtk.Widget) {
                var widget = (Gtk.Widget) child;

                if (widget is Adw.NavigationPage)
                    main_nav_view.add((Adw.NavigationPage) widget);
                else
                    main_toolbar_view.content = widget;
            }
        }

        public void push_by_tag(string tag) {
            main_nav_view.push_by_tag(tag);
        }

        public void pop() {
            main_nav_view.pop();
        }
    }
}
