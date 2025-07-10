using Gee;

namespace Tuner {

    /**
     * Base class for creating custom object tree.
     */
    public class Item : Object, Gtk.Buildable {
        public ArrayList<Item> childs = new ArrayList<Item>();
        public Item? parent { get; set; }
        public string id { get; set; }

        public void insert_after(Item parent, Item? previous_sibling) {
            this.parent = parent;

            if (previous_sibling != null)
                parent.childs.insert(childs.index_of(previous_sibling), this);
            else
                parent.childs.add(this);
        }

        public virtual bool accepts(Item item, string? type) {
            return false;
        }

        public bool visit_children(VisitorFunc visitor) {
            foreach (var child in childs) {
                var res = visitor(child);

                if (res == VisitResult.STOP)
                    return true;

                if (res == VisitResult.RECURSE && child.visit_children(visitor))
                    return true;
            }

            return false;
        }

        private unowned Object get_internal_child(Gtk.Builder builder, string childname) {
            foreach (var child in childs) {
                unowned var weak_child = child;
                if (childname == child.get_buildable_id())
                    return weak_child;
            }
            // Binding again broken, return type should be nullable :crying:
            return null;
        }

        private void add_child(Gtk.Builder builder, Object child, string? type) {
            var item = child as Item;
            if (item == null) {
                warning(@"Attempt to add $(child.get_type().name()) as child of $(get_type().name()), which is not an TunerItem");
                return;
            }
            
            if (!accepts(item, type)) {
                warning(@"Attempt to add $(item.get_type().name()) as child of $(get_type().name()), but that is not allowed");
                return;
            }

            item.insert_after(this, null);
        }

        private void set_id(string id) {
            this.id = id;
        }

        private unowned string get_id() {
            return id;
        }

        public delegate VisitResult VisitorFunc(Item item);

        // Incorrect gtk bindings
        // All methods are virtual but in bindings they are abstract :(
        private void set_buildable_property(Gtk.Builder builder, string name, Value value) {
            set_property(name, value);
        }
        private void parser_finished(Gtk.Builder builder) {}
        private bool custom_tag_start(Gtk.Builder builder, Object? child, string tagname, out Gtk.BuildableParser parser, out void* data) {
            parser = Gtk.BuildableParser();
            data = null;
            return false;
        }
        private void custom_finished(Gtk.Builder builder, Object? child, string tagname, void* data) {}
        private void custom_tag_end(Gtk.Builder builder, Object? child, string tagname, void* data) {}
    }

    public enum VisitResult {
        CONTINUE,
        RECURSE,
        STOP;
    }
}
