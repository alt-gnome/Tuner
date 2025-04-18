namespace Tuner {

    public class ResetButton : Gtk.Button {

        construct {
            tooltip_text = _("Reset");
            icon_name = "edit-undo-symbolic";
            valign = Gtk.Align.CENTER;
            add_css_class("flat");
        }
    }
}
