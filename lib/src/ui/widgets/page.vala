namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/page.ui")]
    public class Page : Adw.NavigationPage, Gtk.Buildable {
        [GtkChild]
        private unowned Adw.PreferencesPage content;

        public void add_content(PageContent page_content) {
            foreach (var extra_group in page_content.extra_groups) {
                content.add(extra_group);

                var group = extra_group as Group;
                if (group != null && group.priority != 0)
                    reorder_group(group);
            }

            foreach (var group_content in page_content.groups) {
                var group = find_group(group_content.get_id());

                if (group != null)
                    group.add_content(group_content);
                else
                    warning(@"Group with id \"$(group_content.get_id())\" not found. Content skipped.");
            }
        }

        public void add(Adw.PreferencesGroup group) {
            content.add(group);
        }

        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (content == null) {
                base.add_child(builder, child, type);
                return;
            }

            if (child is Adw.PreferencesGroup)
                content.add(child as Adw.PreferencesGroup);
        }

        public Gtk.Box get_groups_container() {
            var child = content.get_first_child();

            while (!(child is Gtk.Box))
                child = child.get_first_child();

            return child as Gtk.Box;
        }

        public void reorder_group(Group group) {
            var container = get_groups_container();

            if (group.priority < 0) {
                for (var child = container.get_first_child(); child != null; child = child.get_next_sibling()) {
                    if (child == group) break;

                    var priority = (child is Group) ? ((Group) child).priority : 0;
                    if (priority > group.priority) {
                        group.insert_before(container, child);
                        break;
                    }
                }
            } else {
                for (var child = container.get_last_child().get_prev_sibling(); child != null; child = child.get_prev_sibling()) {
                    var priority = (child is Group) ? ((Group) child).priority : 0;

                    if (priority > group.priority) {
                        group.insert_before(container, child);
                        break;
                    }
                }
            }
        }

        public Group? find_group(string id) {
            for (var child = get_groups_container().get_first_child(); child != null; child = child.get_next_sibling())
                if (child is Group && child.get_id() == id)
                    return child as Group;

            return null;
        }
    }
}
