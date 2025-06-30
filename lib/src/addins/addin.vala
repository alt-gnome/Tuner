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
     *         // Add pages and content from specified ui file
     *         add_from_resource("/org/example/MyAddin/page.ui");
     *
     *         // Add page using method
     *         add_page(new CustomPanelPage());
     *
     *         // Add content using method
     *         add_content(new AppearanceContent());
     *     }
     * }
     * }}}
     */
    public abstract class Addin : Peas.ExtensionBase {
        private ArrayList<PanelPage> page_list = new ArrayList<PanelPage>();
        private ArrayList<PanelPageContent> content_list = new ArrayList<PanelPageContent>();

        /**
         * Virtual method that can be overrided by
         * python plugins instead of using __init__ method
         * to access plugin_info for loading gresources.
         */
        public virtual void activate() {}

        /**
         * Adds pages and content from resource.
         *
         * At any error warning message will be printed.
         *
         * @see Addin.add_from_builder
         */
        public void add_from_resource(string resource_path) {
            try {
                var builder = new Gtk.Builder();
                builder.add_from_resource(resource_path);
                add_from_builder(builder);
            } catch (Error err) {
                warning(@"$(get_type().name()): $(err.message)");
            }
        }

        /**
         * Adds pages and content from file.
         *
         * At any error warning message will be printed.
         *
         * @see Addin.add_from_builder
         */
        public void add_from_file(string filename) {
            try {
                var builder = new Gtk.Builder();
                builder.add_from_file(filename);
                add_from_builder(builder);
            } catch (Error err) {
                warning(@"$(get_type().name()): $(err.message)");
            }
        }

        /**
         * Adds pages and content from string.
         *
         * At any error warning message will be printed.
         *
         * @see Addin.add_from_builder
         */
        public void add_from_string(string str) {
            try {
                var builder = new Gtk.Builder();
                builder.add_from_string(str, str.length);
                add_from_builder(builder);
            } catch (Error err) {
                warning(@"$(get_type().name()): $(err.message)");
            }
        }

        /**
         * Adds pages and content from {@link Gtk.Builder}
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
        public void add_from_builder(Gtk.Builder builder) {
            foreach (var obj in builder.get_objects()) {
                var page = obj as PanelPage;
                if (page != null && page.is_toplevel)
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
