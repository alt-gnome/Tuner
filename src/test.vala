public class TestTest : Peas.ExtensionBase, Tuner.PageAddin {
    public unowned List<Tuner.PanelPage> pages { get; set; }

    construct {
        pages = new List<Tuner.PanelPage>();
        pages.append(new Tuner.PanelPage() {
            title = "Test",
            icon_name = "appearance-symbolic"
        });
        pages.append(new Tuner.PanelPage() {
            title = "Test",
            icon_name = "appearance-symbolic",
            category = "cat1"
        });
        pages.append(new Tuner.PanelPage() {
            title = "Test",
            icon_name = "appearance-symbolic",
            category = "cat1"
        });
        pages.append(new Tuner.PanelPage() {
            title = "Test",
            icon_name = "appearance-symbolic",
            category = "cat2"
        });
        pages.append(new Tuner.PanelPage() {
            title = "Test",
            icon_name = "appearance-symbolic",
            category = "cat1"
        });
    }
}

public void peas_register_types(TypeModule module) {
    var obj = (Peas.ObjectModule) module;
    obj.register_extension_type(typeof(Tuner.PageAddin), typeof(TestTest));
}
