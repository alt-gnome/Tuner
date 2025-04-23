namespace Tuner {

    public class PanelPageContent : Gtk.Widget, Gtk.Buildable {
        public string tag { get; set; }
        public Gee.ArrayList<PageContent> pages = new Gee.ArrayList<PageContent>();
        public Gee.ArrayList<Adw.NavigationPage> extra_pages = new Gee.ArrayList<Adw.NavigationPage>();

        public PageContent get_main_page() {
            var page = pages.first_match(it => it.tag == "main");

            if (page == null) {
                page = new PageContent();
                pages.add(page);
            }

            return page;
        }

        public void add_page(PageContent content) {
            var page = pages.first_match(it => it.tag == content.tag);

            if (page != null) {
                page.merge(content);
            } else {
                pages.add(content);
            }
        }

        public void add_extra_page(Adw.NavigationPage page) {
            extra_pages.add(page);
        }

        public void add_group(GroupContent content) {
            get_main_page().add_group(content);
        }

        public void add(Adw.PreferencesGroup child) {
            get_main_page().add(child);
        }

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
