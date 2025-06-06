namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/panel-list-row.ui")]
    public class PanelListRow : Adw.PreferencesRow {
        public PanelPage page { get; set; }
        public string icon_name { get; set; }
        public bool show_next_icon { get; set; }

        public PanelListRow(PanelPage page) {
            this.page = page;

            page.bind_property("title", this, "title", BindingFlags.SYNC_CREATE);
            page.bind_property("icon-name", this, "icon-name", BindingFlags.SYNC_CREATE);

            if (page.layout_type != LayoutType.INTERNAL)
                show_next_icon = true;
        }
    }
}
