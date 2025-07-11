namespace Tuner {

    /**
     * Simple builder implementation for toplevel {@link Page}.
     * Creates Adw.NavigationPage with Adw.NavigationView and
     * stores internal subpages inside it.
     *
     * Note: Used by host app, do not use that class in your plugins!
     */
    [GtkTemplate (ui = "/org/altlinux/Tuner/panel.ui")]
    public class Panel : Adw.NavigationPage {
        [GtkChild]
        private unowned Adw.NavigationView main_nav_view;
        [GtkChild]
        private unowned PanelPage main_page;

        public unowned Page? page { get; set; }

        public Panel() {}

        public Panel.with_page(Page page) {
            this.page = page;
            build();
        }

        private void build() {
            if (page == null) return;

            main_page.page = page;
            main_page.build();
            page.visit_children(visitor);
        }

        public VisitResult visitor(Item item) {
            var page = item as Page;
            if (page != null && !page.in_stack) {
                main_nav_view.add(new PanelPage.with_page(page));
            }
            return VisitResult.CONTINUE;
        }
    }
}
