using Gee;

namespace Tuner {

    /**
     * Group that can contain widgets.
     */
    public class Group : Item {
        public string title { get; set; }
        public string description { get; set; }
        public Gtk.Widget? header_suffix { get; set; }
        public int priority { get; set; }

        public void add(Widget widget) {
            widget.insert_after(this, null);
        }

        public void merge(Group group) {
            foreach (var child in group.childs)
                child.insert_after(this, null);

            if (header_suffix == null && group.header_suffix != null)
                header_suffix = group.header_suffix;
        }

        public override bool accepts(Item item, string? type) {
            return item is Widget;
        }
    }
}
