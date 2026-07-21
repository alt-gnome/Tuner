namespace Tuner {

    public class Scale : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public Gtk.Scale? marked_scale { get; set; }
        public Gtk.Adjustment? adjustment { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var adjustment = binding.create_adjustment();
                if (adjustment == null && this.adjustment == null)
                    return null;

                var row = new Adw.ActionRow() {
                    title = title,
                    subtitle = subtitle
                };

                var scale = marked_scale;

                if (scale == null) {
                    scale = new Gtk.Scale(Gtk.Orientation.HORIZONTAL, this.adjustment ?? adjustment) {
                        hexpand = true
                    };
                } else {
                    scale.adjustment = this.adjustment ?? adjustment;
                    scale.orientation = Gtk.Orientation.HORIZONTAL;
                    scale.hexpand = true;
                }

                row.add_suffix(scale);
                row.activatable_widget = scale;

                binding.bind(adjustment, "value");
                return row;
            }

            return null;
        }
    }
}
