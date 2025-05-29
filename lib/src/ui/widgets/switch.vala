namespace Tuner {

    public class Switch : Tuner.Widget {
        public string title { get; set; }
        public string subtitle { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new SwitchRow() {
                    title = title,
                    subtitle = subtitle
                };
                row.setup(binding);
                binding.bind(row, "active");

                return row;
            }

            return null;
        }
    }
}
