namespace Tuner {

    /**
     * Button with icon-name: edit-undo-symbolic, flat as css class and valign is center
     */
    public class ResetButton : Gtk.Box {
        private Gtk.Revealer? _revealer;
        private Gtk.Button button;

        public Gtk.Align revealer {
            set {
                if (_revealer != null)
                    remove(_revealer);

                if (value != Gtk.Align.END && value != Gtk.Align.START)
                    return;

                _revealer = new Gtk.Revealer() {
                    transition_type = Gtk.RevealerTransitionType.CROSSFADE,
                    reveal_child = true,
                    child = new Adw.Bin() {
                        child = new Gtk.Separator(Gtk.Orientation.VERTICAL) {
                            margin_start = 6,
                            margin_end = 6
                        }
                    }
                };

                button.state_flags_changed.connect(() => {
                    var flags = button.get_state_flags();
                    var is_prelight = Gtk.StateFlags.PRELIGHT in flags;
                    var is_activated = (Gtk.StateFlags.SELECTED | Gtk.StateFlags.CHECKED) in flags;
                    var is_focused = Gtk.StateFlags.FOCUSED in flags || Gtk.StateFlags.FOCUS_VISIBLE in flags;

                    _revealer.set_reveal_child(!(is_prelight || is_activated || is_focused));
                });

                if (value == Gtk.Align.END)
                    append(_revealer);
                else
                    prepend (_revealer);
            }
        }

        construct {
            orientation = Gtk.Orientation.HORIZONTAL;

            append(button = new Gtk.Button() {
                tooltip_text = _("Reset"),
                icon_name = "edit-undo-symbolic",
                valign = Gtk.Align.CENTER
            });
            button.add_css_class("flat");
            button.clicked.connect(() => reset());
        }

        public signal void reset();
    }
}
