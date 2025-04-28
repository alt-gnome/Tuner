namespace Tuner {

    /**
     * Abstract base class for plugins that add content to existing {@link Tuner.PanelPage}s.
     *
     * Extend this class to create plugins that can contribute UI elements to panel pages.
     * The plugin must implement the `content_list` property to provide its content.
     *
     * Example
     * {{{
     * public class MyContentPlugin : Tuner.ContentAddin {
     *     public override unowned List<Tuner.PanelPageContent> content_list { get; set; }
     *
     *     construct {
     *         content_list = new List<Tuner.PanelPageContent>();
     *         content_list.append(new CustomPanelPageContent());
     *     }
     * }
     * }}}
     */
    public abstract class ContentAddin : Peas.ExtensionBase {
        /**
         * The list of {@link Tuner.PanelPageContent} that this addin provides.
         */
        public abstract unowned List<Tuner.PanelPageContent> content_list { get; set; }
    }
}
