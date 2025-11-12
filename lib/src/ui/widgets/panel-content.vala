namespace Tuner {

    public class PanelContent : Adw.PreferencesPage {
        private Adw.PreferencesGroup current_group;

        public unowned Page? page { get; set; }

        public PanelContent.with_page(Page page) {
            this.page = page;
            page.visit_children(visitor);
        }

        public void build() {
            if (page == null) return;

            page.visit_children(visitor);
        }

        private new void add(Adw.PreferencesGroup group) {
            base.add(group);

            if (group.get_data<int>("priority") != 0)
                reorder_group(group);
        }

        /**
         * Gets the container widget that holds all preference groups.
         *
         * @return The {@link Gtk.Box} containing the groups
         */
        public Gtk.Box get_groups_container() {
            var child = get_first_child();

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
                    visible = group.show_empty
                };
                current_group.set_data<int>("priority", group.priority);
                add(current_group);

                return VisitResult.RECURSE;
            } else if (item is Widget) {
                var widget = (Widget) item;
                var child = widget.native_widget;

                if (child != null) {
                    current_group.add(child);
                    if (child.visible)
                        current_group.visible = true;
                }
            }
            return VisitResult.CONTINUE;
        }
    }
}
