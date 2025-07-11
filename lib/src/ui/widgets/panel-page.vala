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
        [GtkChild]
        private unowned Adw.ToolbarView toolbar_view;
        [GtkChild]
        private unowned Adw.HeaderBar header_bar;
        private PanelContent? content;
        private Adw.ViewStack? stack;

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

            if (page.title_widget != null && !page.has_subpages)
                header_bar.title_widget = page.title_widget;

            if (page.start_widgets != null && !page.has_subpages)
                foreach (var widget in page.start_widgets)
                    header_bar.pack_start(widget);

            if (page.end_widgets != null && !page.has_subpages)
                foreach (var widget in page.end_widgets)
                    header_bar.pack_end(widget);

            if (page.top_widgets != null && !page.has_subpages)
                foreach (var widget in page.top_widgets)
                    toolbar_view.add_top_bar(widget);

            if (page.bottom_widgets != null && !page.has_subpages)
                foreach (var widget in page.bottom_widgets)
                    toolbar_view.add_bottom_bar(widget);

            if (page.has_stack_pages) {
                foreach (var stack_page in page.stack_pages) {
                    add_stack_page(stack_page);
                }
            } else {
                toolbar_view.content = content = new PanelContent.with_page(page);
            }
        }

        public void add_stack_page(Page stack_page) {
            if (stack == null) {
                toolbar_view.content = stack = new Adw.ViewStack() {
                    enable_transitions = true
                };
                page.stack = stack;
            }

            stack.add_titled_with_icon(new PanelContent.with_page(stack_page), stack_page.tag, stack_page.title, stack_page.icon_name);
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
    }
}
