namespace Tuner {

    public abstract class ContentAddin : Peas.ExtensionBase {
        public abstract unowned List<Tuner.PanelPageContent> content_list { get; set; }
    }
}
