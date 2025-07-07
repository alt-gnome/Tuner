namespace Tuner {

    /**
     * Simple builder implementation for {@link Page} class.
     * Creates Adw.NavigationPage with Adw.HeaderBar on top.
     * Sync 'tag' and 'title' with {@link Page}
     *
     * Note: Used by host app, do not use that class in your plugins!
     */
    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-page.ui")]
    public class PanelPage : Adw.NavigationPage {
        private Adw.PreferencesGroup current_group;

        [GtkChild]
        private unowned Adw.ToolbarView toolbar_view;
        [GtkChild]
        private unowned Adw.HeaderBar header_bar;
        [GtkChild]
        private unowned Adw.PreferencesPage content;

        public unowned Page? page { get; set; }

        public PanelPage() {}

        public PanelPage.with_page(Page page) {
            this.page = page;
            build();
        }

        public void build() {
            if (page == null) return;

            title = page.title;
            tag = page.tag;
            page.visit_children(visitor);
        }

        public void add(Adw.PreferencesGroup group) {
            content.add(group);

            if (group.get_data<int>("priority") != 0)
                reorder_group(group);
        }

        public void pack_start(Gtk.Widget child) {
            header_bar.pack_start(child);
        }

        public void pack_end(Gtk.Widget child) {
            header_bar.pack_end(child);
        }

        /**
         * Adds a bottom bar to toolbar view
         */
        public void add_top_bar(Gtk.Widget widget) {
            toolbar_view.add_top_bar(widget);
        }

        /**
         * Adds a bottom bar to toolbar view
         */
        public void add_bottom_bar(Gtk.Widget widget) {
            toolbar_view.add_bottom_bar(widget);
        }
        /**
         * Gets the container widget that holds all preference groups.
         *
         * @return The {@link Gtk.Box} containing the groups
         */
        public Gtk.Box get_groups_container() {
            var child = content.get_first_child();

            while (!(child is Gtk.Box))
                child = child.get_first_child();

            return child as Gtk.Box;
        }

        /**
         * Reorders a group based on its priority value.
         *
         * @param group The {@link Tuner.Group} to reorder
         */
        public void reorder_group(Adw.PreferencesGroup group) {
            var container = get_groups_container();

            if (group.get_data<int>("priority") < 0) {
                for (var child = container.get_first_child(); child != null; child = child.get_next_sibling()) {
                    if (child == group) break;

                    var priority = child.get_data<int>("priority");
                    if (priority > group.get_data<int>("priority")) {
                        group.insert_before(container, child);
                        break;
                    }
                }
            } else {
                for (var child = container.get_last_child().get_prev_sibling();child != null; child = child.get_prev_sibling()) {
                    var priority = child.get_data<int>("priority");

                    if (priority > group.get_data<int>("priority")) {
                        group.insert_before(container, child);
                        break;
                    }
                }
            }
        }

        private VisitResult visitor(Item item) {
            if (item is Group) {
                var group = (Group) item;
                string title = null;
                string description = null;

                if (group.title != null)
                    title = Markup.escape_text(group.title);

                if (group.description != null)
                    description = Markup.escape_text(group.description);

                current_group = new Adw.PreferencesGroup() {
                    title = title,
                    description = description,
                    header_suffix = group.header_suffix,
                    visible = false
                };
                current_group.set_data<int>("priority", group.priority);
                add(current_group);

                return VisitResult.RECURSE;
            } else if (item is Widget) {
                var widget = (Widget) item;
                var child = widget.create();

                if (child != null) {
                    current_group.add(child);
                    current_group.visible = true;
                }
            }
            return VisitResult.CONTINUE;
        }
    }
}
