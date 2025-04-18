namespace Tuner {

    public abstract class PageAddin : Peas.ExtensionBase {
        public abstract unowned List<Tuner.PanelPage> pages { get; set; }
    }
}
