namespace Tuner {

    /**
     * A top-level page that represents a settings row in the application.
     *
     * Tag must be specified in order to allow other plugins extend it contents.
     */
    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-page.ui")]
    public class PanelPage : Adw.NavigationPage, Gtk.Buildable {
        [GtkChild]
        private unowned Adw.NavigationView main_nav_view;
        [GtkChild]
        private unowned Page main_page;

        public bool is_toplevel = true;
        public ListStore? model { get; set; }
        public Adw.NavigationPage? custom_content { get; set; }
        public LayoutType layout_type { get; set; default = LayoutType.INTERNAL; }
        /**
         * The icon name displayed in the side panel for this page.
         * Should be a symbolic icon from the current icon theme.
         */
        public string icon_name { get; set; }
        /**
         * The category this panel page.
         */
        public string category { get; set; }
        /**
         * Determines ordering of this page in the side panel.
         * Lower values appear higher in the list.
         */
        public int priority { get; set; }

        /**
         * {@inheritDoc}
         */
        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (main_nav_view == null) {
                base.add_child(builder, child, type);
                return;
            }

            if (type == "custom-content") {
                custom_content = child as Adw.NavigationPage;
                return;
            }

            if (child is PanelPage) {
                var page = (PanelPage) child;

                page.is_toplevel = false;
                add_subpage(page);
            } else if (child is Adw.NavigationPage) {
                add((Adw.NavigationPage) child);
            } else if (child is Adw.PreferencesGroup) {
                add_group((Adw.PreferencesGroup) child);
            }
        }

        public void add_subpage(PanelPage page) {
            if (model == null)
                model = new ListStore(typeof(PanelPage));

            model.insert_sorted(page, (a, b) => ((PanelPage) a).priority - ((PanelPage) b).priority);
        }

        /**
         * Adds content from a {@link Tuner.PanelPageContent} builder.
         */
        public void add_content(PanelPageContent content) {
            foreach (var page in content.extra_pages)
                add(page);

            foreach (var page_content in content.pages) {
                var page = find_page(page_content.tag) as Page;
                if (page != null)
                    page.add_content(page_content);
                else
                    warning(@"Page with tag \"$(page_content.tag)\" not found. Content skipped.");
            }
        }

        /**
         * Permanently adds group to main page.
         */
        public void add_group(Adw.PreferencesGroup group) {
            main_page.add(group);
        }

        /**
         * Permanently adds page to this.
         */
        public void add(Adw.NavigationPage page) {
            main_nav_view.add(page);
        }

        /**
         * Finds a page in this by its tag.
         * @see Adw.NavigationPage.tag
         */
        public unowned Adw.NavigationPage? find_page(string tag) {
            return main_nav_view.find_page(tag);
        }

        /**
         * Pushes page onto the navigation stack.
         */
        public void push(Adw.NavigationPage page) {
            main_nav_view.push(page);
        }

        /**
         * Pushes the page with the tag tag onto the navigation stack.
         */
        public void push_by_tag(string tag) {
            main_nav_view.push_by_tag(tag);
        }

        /**
         * Pops the visible page from the navigation stack.
         */
        public void pop() {
            main_nav_view.pop();
        }

        /**
         * Pops pages from the navigation stack until page is visible.
         */
        public void pop_to_page(Adw.NavigationPage page) {
            main_nav_view.pop_to_page(page);
        }

        /**
         * Pops pages from the navigation stack until page with the tag tag is visible.
         */
        public void pop_to_tag(string tag) {
            main_nav_view.pop_to_tag(tag);
        }
    }
}
