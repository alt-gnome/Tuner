namespace Tuner {

    /**
     * Color row widget
     */
    public class Color : Tuner.Widget {
        public string title { get; set; }
        public string subtitle { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new ColorRow() {
                    title = title,
                    subtitle = subtitle
                };
                row.setup(binding);
                binding.bind(row, "color");

                return row;
            }

            return null;
        }
    }
}
