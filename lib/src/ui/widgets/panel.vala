namespace Tuner {

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
            if (item is Page) {
                main_nav_view.add(new PanelPage.with_page((Page) item));
            }
            return VisitResult.CONTINUE;
        }
    }
}
