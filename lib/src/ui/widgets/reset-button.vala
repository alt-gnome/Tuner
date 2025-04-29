namespace Tuner {

    /**
     * Button with icon-name: edit-undo-symbolic, flat as css class and valign is center
     */
    public class ResetButton : Gtk.Button {

        construct {
            tooltip_text = _("Reset");
            icon_name = "edit-undo-symbolic";
            valign = Gtk.Align.CENTER;
            add_css_class("flat");
        }
    }
}
