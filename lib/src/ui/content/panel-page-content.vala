namespace Tuner {

    /**
     * Builder class for adding UI content to an existing {@link Tuner.PanelPage}.
     *
     * Used by plugins to extend panel pages with additional groups and pages. Typically
     * declared in UI templates.
     *
     * Example
     * {{{
     * // Add content to panel with tag "appearance"
     * Tuner.PanelPageContent {
     *     tag: "appearance";
     *
     *     // Add a group at the beginning
     *     Tuner.Group new_group_addin {
     *         priority: -1;
     *         title: _("First group title");
     *
     *         Adw.ActionRow {}
     *     }
     *
     *     // Add an extra navigation page
     *     Adw.NavigationPage {
     *         // ... page content ...
     *     }
     * }
     * }}}
     */
    public class PanelPageContent : Gtk.Widget, Gtk.Buildable {
        /**
         * The tag of the target {@link Tuner.PanelPage} to add content to.
         * Must match an existing panel page's tag.
         */
        public string tag { get; set; }

        /**
         * List of {@link Tuner.PageContent} objects to add to the panel.
         */
        public Gee.ArrayList<PageContent> pages = new Gee.ArrayList<PageContent>();

        /**
         * List of additional {@link Adw.NavigationPage} to extend the panel.
         */
        public Gee.ArrayList<Adw.NavigationPage> extra_pages = new Gee.ArrayList<Adw.NavigationPage>();

        internal PageContent get_main_page() {
            var page = pages.first_match(it => it.tag == "main");

            if (page == null) {
                page = new PageContent();
                pages.add(page);
            }

            return page;
        }

        /**
         * Adds a {@link Tuner.PageContent} to this builder.
         * Merges content if page with same tag exists.
         */
        public void add_page(PageContent content) {
            var page = pages.first_match(it => it.tag == content.tag);

            if (page != null) {
                page.merge(content);
            } else {
                pages.add(content);
            }
        }

        /**
         * Adds an extra {@link Adw.NavigationPage} to the panel.
         */
        public void add_extra_page(Adw.NavigationPage page) {
            extra_pages.add(page);
        }

        /**
         * Adds a {@link Tuner.GroupContent} to the panel's main page.
         */
        public void add_group(GroupContent content) {
            get_main_page().add_group(content);
        }

        /**
         * Adds a {@link Adw.PreferencesGroup} directly to the panel's main page.
         */
        public void add(Adw.PreferencesGroup child) {
            get_main_page().add(child);
        }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, Object child, string? type) {
            if (child is PageContent) {
                add_page(child as PageContent);
            } else if (child is GroupContent) {
                add_group(child as GroupContent);
            } else if (child is Adw.NavigationPage) {
                extra_pages.add(child as Adw.NavigationPage);
            } else if (child is Adw.PreferencesGroup) {
                add(child as Adw.PreferencesGroup);
            } else {
                message(@"Unknown child type found while building content for \"$tag\": $(child.get_type().name())");
            }
        }
    }
}
