namespace Tuner {

    public class ColorIndicator : Gtk.Widget {
        public Gdk.RGBA rgba { get; set; default = { 0, 0, 0, 1 }; }

        construct {
            notify["rgba"].connect(() => queue_draw());
        }

        public override void snapshot(Gtk.Snapshot snapshot) {
            var rect = Graphene.Rect().init(0, 0, get_width(), get_height());
            var round_rect = Gsk.RoundedRect().init_from_rect(rect, 100);
            snapshot.push_rounded_clip(round_rect);
            snapshot.append_color(rgba, rect);
            snapshot.pop();
        }
    }
}
