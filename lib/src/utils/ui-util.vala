namespace Tuner {

    internal static void setup_separator_revealer(
        Gtk.Revealer revealer,
        Gtk.Widget widget
    ) {
        revealer.set_reveal_child(true);

        revealer.reveal_child = true;
        widget.state_flags_changed.connect(() => {
            var flags = widget.get_state_flags();
            var is_prelight = Gtk.StateFlags.PRELIGHT in flags;
            var is_activated = (Gtk.StateFlags.SELECTED | Gtk.StateFlags.CHECKED) in flags;
            var is_focused = Gtk.StateFlags.FOCUSED in flags || Gtk.StateFlags.FOCUS_VISIBLE in flags;

            revealer.set_reveal_child(!(is_prelight || is_activated || is_focused));
        });

        widget.bind_property("visible", revealer, "visible", BindingFlags.SYNC_CREATE);
        widget.bind_property("opacity", revealer, "opacity", BindingFlags.SYNC_CREATE);
    }
}
