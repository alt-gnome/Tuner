namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-page.ui")]
    public class PanelPage : Adw.NavigationPage, Gtk.Buildable {
        [GtkChild]
        private unowned Adw.NavigationView main_nav_view;
        [GtkChild]
        private unowned Page main_page;

        public string icon_name { get; set; }
        public string category { get; set; }
        public int priority { get; set; }

        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (main_nav_view == null) {
                base.add_child(builder, child, type);
                return;
            }

            if (child is Adw.NavigationPage)
                main_nav_view.add((Adw.NavigationPage) child);
            else if (child is Adw.PreferencesGroup)
                main_page.add((Adw.PreferencesGroup) child);
        }

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

        public void add(Adw.NavigationPage page) {
            main_nav_view.add(page);
        }

        public unowned Adw.NavigationPage? find_page(string tag) {
            return main_nav_view.find_page(tag);
        }

        public void push_by_tag(string tag) {
            main_nav_view.push_by_tag(tag);
        }

        public void pop() {
            main_nav_view.pop();
        }
    }
}
