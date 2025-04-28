namespace Tuner {

    /**
     * Builder class for adding widgets to an existing {@link Tuner.Group}.
     *
     * Used by plugins to extend groups with additional UI widgets.
     *
     * Example
     * {{{
     * // Add content to group with ID "target_group_id"
     * Tuner.GroupContent target_group_id {
     *     Adw.ActionRow {}
     * }
     * }}}
     */
    public class GroupContent : Gtk.Widget, Gtk.Buildable {
        /**
         * List of widgets to add to the target group.
         */
        public Gee.ArrayList<Gtk.Widget> childs = new Gee.ArrayList<Gtk.Widget>();

        /**
         * Adds a widget to this group content.
         */
        public void add(Gtk.Widget child) {
            childs.add(child);
        }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, Object child, string? type) {
            if (child is Gtk.Widget)
                add(child as Gtk.Widget);
            else
                message(@"Unknown child type found while building content for \"$(get_id())\" group: $(child.get_type().name())");
        }

        internal void merge(GroupContent other) {
            childs.add_all(other.childs);
        }
    }
}
