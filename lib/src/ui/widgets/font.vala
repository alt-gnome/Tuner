namespace Tuner {

    public class Font : Tuner.Widget {
        public string title { get; set; }

        public override Gtk.Widget? create() {
            if (binding != null) {
                var row = new FontRow() {
                    title = title
                };
                row.setup(binding);
                binding.bind(row, "font");

                return row;
            }

            return null;
        }
    }
}
