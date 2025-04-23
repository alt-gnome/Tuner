namespace Tuner {

    public class GroupContent : Gtk.Widget, Gtk.Buildable {
        public Gee.ArrayList<Gtk.Widget> childs = new Gee.ArrayList<Gtk.Widget>();

        public void add(Gtk.Widget child) {
            childs.add(child);
        }

        public void add_child(Gtk.Builder builder, Object child, string? type) {
            if (child is Gtk.Widget) {
                add(child as Gtk.Widget);
            } else {
                message(@"Unknown child type found while building content for \"$(get_id())\" group: $(child.get_type().name())");
            }
        }

        public void merge(GroupContent other) {
            childs.add_all(other.childs);
        }
    }
}
