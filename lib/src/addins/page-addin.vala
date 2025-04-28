namespace Tuner {

    /**
     * Abstract base class for plugins that add new {@link Tuner.PanelPage}s.
     *
     * Extend this class to create plugins that can contribute complete panel pages.
     * The plugin must implement the `pages` property to provide its pages.
     *
     * Example
     * {{{
     * public class MyPagePlugin : Tuner.PageAddin {
     *     public override unowned List<Tuner.PanelPage> pages { get; set; }
     *
     *     construct {
     *         pages = new List<Tuner.PanelPage>();
     *         pages.append(new CustomPanelPage());
     *     }
     * }
     * }}}
     */
    public abstract class PageAddin : Peas.ExtensionBase {
        /**
         * The list of {@link Tuner.PanelPage} that this addin provides.
         */
        public abstract unowned List<Tuner.PanelPage> pages { get; set; }
    }
}
