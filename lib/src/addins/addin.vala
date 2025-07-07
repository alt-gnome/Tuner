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
        private ArrayList<Page> page_list = new ArrayList<Page>();

        /**
         * Virtual method that can be overrided by
         * python plugins instead of using __init__ method
         * to access plugin_info for loading gresources.
         */
        public virtual void activate() {}

        /**
         * Adds pages from resource.
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
                warning(@"$(get_type().name()) ($(resource_path)): $(err.message)");
            }
        }

        /**
         * Adds pages from file.
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
                warning(@"$(get_type().name()) ($filename): $(err.message)");
            }
        }

        /**
         * Adds pages from string.
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
                warning(@"$(get_type().name()) (from string): $(err.message)");
            }
        }

        /**
         * Adds pages from {@link Gtk.Builder}
         *
         * Example
         * {{{
         * using Gtk 4.0;
         * using Tuner 1;
         *
         * translation-domain "my-translations";
         *
         * Tuner.Page {
         *     tag: "my-page-tag";
         *     title: _("Translatable title");
         *
         *     ...
         * }
         *
         * Tuner.Page {
         *     // Add page with tag appearance
         *     // If page with that tag already added
         *     // Their content will be merged
         *     tag: "appearance";
         *     title: _("Appearance");
         *
         *     ...
         * }
         * }}}
         */
        public void add_from_builder(Gtk.Builder builder) {
            foreach (var obj in builder.get_objects()) {
                var page = obj as Page;
                if (page != null && page.parent == null) {
                    add_page((Page) obj);
                }
            }
        }

        /**
         * Add page directly to this
         */
        public void add_page(Page page) {
            page_list.add(page);
        }

        /**
         * Return current pages in this
         */
        public ArrayList<Page> get_page_list() {
            return page_list;
        }
    }
}
