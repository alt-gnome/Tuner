namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-row.ui")]
    internal class PanelRow : Adw.PreferencesRow {
        public PanelPage page { get; set; }
        public string icon_name { get; set; }

        public PanelRow(PanelPage page) {
            this.page = page;

            page.bind_property("title", this, "title", BindingFlags.SYNC_CREATE);
            page.bind_property("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);
        }
    }
}
