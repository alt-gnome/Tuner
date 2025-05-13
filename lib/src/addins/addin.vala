using Gee;

namespace Tuner {

    /**
     * Abstract base class for plugins.
     *
     * Extend this class to create plugins that can provide
     * new panel pages and content for pages.
     *
     * Example
     * {{{
     * public class MyAddin : Tuner.Addin {
     *
     *     construct {
     *         add_from_resource("/org/example/MyAddin/page.ui");
     *         add_page(new CustomPanelPage());
     *         add_content(new AppearanceContent());
     *     }
     * }
     * }}}
     */
    public abstract class Addin : Peas.ExtensionBase {
        private ArrayList<PanelPage> page_list = new ArrayList<PanelPage>();
        private ArrayList<PanelPageContent> content_list = new ArrayList<PanelPageContent>();

        /**
         * Adds pages and content from resource.
         * 
         * Example
         * {{{
         * using Gtk 4.0;
         * using Tuner 1;
         *
         * translation-domain "my-translations";
         *
         * Tuner.PanelPage {
         *     tag: "my-page-tag";
         *     title: _("Translatable title");
         *
         *     ...
         * }
         *
         * Tuner.PanelPageContent {
         *     tag: "appearance"; // Add content to page with tag appearance
         *
         *     ...
         * }
         * }}}
         */
        public void add_from_resource(string resource_path) {
            if (!File.new_for_uri(@"resource://$resource_path").query_exists()) {
                warning(@"Resource \"$resource_path\" not found, skipped.");
                return;
            }

            var builder = new Gtk.Builder.from_resource(resource_path);

            foreach (var obj in builder.get_objects()) {
                if (obj is PanelPage)
                    page_list.add((PanelPage) obj);

                if (obj is PanelPageContent)
                    content_list.add((PanelPageContent) obj);
            }
        }

        /**
         * Add page directly to this
         */
        public void add_page(PanelPage page) {
            page_list.add(page);
        }

        /**
         * Add content directly to this
         */
        public void add_content(PanelPageContent content) {
            content_list.add(content);
        }

        /**
         * Return current pages in this
         */
        public ArrayList<PanelPage> get_page_list() {
            return page_list;
        }

        /**
         * Return current content in this
         */
        public ArrayList<PanelPageContent> get_content_list() {
            return content_list;
        }
    }
}
