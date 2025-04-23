namespace Tuner {

    public class PageContent : Gtk.Widget {
        public string tag { get; set; default = "main"; }
        public Gee.ArrayList<GroupContent> groups = new Gee.ArrayList<GroupContent>();
        public Gee.ArrayList<Adw.PreferencesGroup> extra_groups = new Gee.ArrayList<Adw.PreferencesGroup>();

        public void add_group(GroupContent content) {
            var group = get_group(content.get_id());

            if (group != null) {
                group.merge(content);
            } else {
                groups.add(content);
            }
        }

        public void add(Adw.PreferencesGroup child) {
            extra_groups.add(child);
        }

        public GroupContent? get_group(string id) {
            return groups.first_match(it => it.get_id() == id);
        }

        public void add_child(Gtk.Builder builder, Object child, string? type) {
            if (child is GroupContent) {
                add_group(child as GroupContent);
            } else if (child is Adw.PreferencesGroup) {
                add(child as Adw.PreferencesGroup);
            } else {
                message(@"Unknown child type found while building content for \"$tag\" page: $(child.get_type().name())");
            }
        }

        public void merge(PageContent other) {
            groups.add_all(other.groups);
            extra_groups.add_all(other.extra_groups);
        }
    }
}
