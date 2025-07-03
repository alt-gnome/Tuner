namespace Tuner {

    public class Spin : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public uint digits { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var adjustment = binding.create_adjustment();
                if (adjustment == null)
                    return null;

                var row = new Adw.SpinRow(adjustment, 0, digits) {
                    title = title,
                    subtitle = subtitle
                };

                binding.bind(adjustment, "value");
                return row;
            }

            return null;
        }
    }
}
