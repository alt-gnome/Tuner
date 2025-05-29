using Gee;

namespace Tuner {

    /**
     * Widget allows to use Content addins
     *
     * Content addins can be added using
     * widget id if it was specified.
     */
    public class Group : Adw.PreferencesGroup, Gtk.Buildable {
        private ArrayList<Widget> widgets = new ArrayList<Widget>();
        public int priority { get; set; }

        public void add_content(GroupContent content) {
            foreach (var child in content.childs)
                add(child);
        }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, Object child, string? type) {
            add(child);
        }

        public new void add(Object child) {
            if (child is Widget) {
                widgets.add((Widget) child);

                var widget = ((Widget) child).create();
                if (widget != null)
                    base.add(widget);
            } else {
                base.add(child as Gtk.Widget);
            }
        }
    }
}
