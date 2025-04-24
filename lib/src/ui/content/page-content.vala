namespace Tuner {

    /**
     * Builder class for adding UI content to an existing {@link Tuner.Page}.
     *
     * Used by plugins to extend pages with additional groups and widgets.
     *
     * === Example ===
     * {{{
     *     // Add content to page with tag "target_page_id"
     *     Tuner.PageContent {
     *         tag: "target_page_id";
     *
     *         // Add to existing group "target_group_id"
     *         Tuner.GroupContent target_group_id {
     *             Adw.ActionRow {}
     *         }
     *
     *         // Create new unnamed group
     *         Tuner.Group extra {
     *             Adw.ActionRow {}
     *         }
     *     }
     * }}}
     */
    public class PageContent : Gtk.Widget {
        /**
         * The tag of the target {@link Tuner.Page} to modify.
         * Defaults to "main" page if not specified.
         */
        public string tag { get; set; default = "main"; }

        /**
         * List of {@link Tuner.GroupContent} to add to the page.
         */
        public Gee.ArrayList<GroupContent> groups = new Gee.ArrayList<GroupContent>();

        /**
         * List of additional {@link Adw.PreferencesGroup} widgets.
         */
        public Gee.ArrayList<Adw.PreferencesGroup> extra_groups = new Gee.ArrayList<Adw.PreferencesGroup>();

        /**
         * Adds a {@link Tuner.GroupContent} to this page.
         * Merges content if group with same ID exists.
         */
        public void add_group(GroupContent content) {
            var group = get_group(content.get_id());

            if (group != null) {
                group.merge(content);
            } else {
                groups.add(content);
            }
        }

        /**
         * Adds a {@link Adw.PreferencesGroup} directly to this page.
         */
        public void add(Adw.PreferencesGroup child) {
            extra_groups.add(child);
        }

        /**
         * Finds a {@link Tuner.GroupContent} by its ID.
         *
         * @param id The group ID to search for
         * @return The matching group or null if not found
         */
        public GroupContent? get_group(string id) {
            return groups.first_match(it => it.get_id() == id);
        }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, Object child, string? type) {
            if (child is GroupContent) {
                add_group(child as GroupContent);
            } else if (child is Adw.PreferencesGroup) {
                add(child as Adw.PreferencesGroup);
            } else {
                message(@"Unknown child type found while building content for \"$tag\" page: $(child.get_type().name())");
            }
        }

        internal void merge(PageContent other) {
            groups.add_all(other.groups);
            extra_groups.add_all(other.extra_groups);
        }
    }
}
