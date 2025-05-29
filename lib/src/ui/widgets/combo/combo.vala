namespace Tuner {

    public class Combo : Tuner.Widget, Gtk.Buildable {
        public string title { get; set; }
        public string subtitle { get; set; }
        public ListStore model;

        construct {
            model = new ListStore(typeof(Choice));
        }

        public void add_child(Gtk.Builder builder, Object child, string? type) {
            if (child is Choice) {
                add_choice(child as Choice);
            } else if (child is ChoiceLoader) {
                add_loader(child as ChoiceLoader);
            }
        }

        public void add_choice(Choice choice) {
            model.append(choice);
        }

        public void add_loader(ChoiceLoader loader) {
            loader.load(model);
        }

        public override Gtk.Widget? create() {
            if (binding != null) {
                int selected = 0;

                var type = binding.expected_type;
                if (type != Type.INVALID) {
                    var value = Value(type);
                    if (binding.get_value(ref value)) {
                        var variant = convert_from_value(value, to_variant_type(type));

                        for (int i = 0; i < model.n_items; i++) {
                            var choice = (Choice) model.get_item(i);
                            if (choice.value.equal(variant)) {
                                selected = i;
                                break;
                            }
                        }
                    }
                }

                var row = new ComboRow(binding, model, selected) {
                    title = title,
                    subtitle = subtitle
                };

                return row;
            }

            return null;
        }
    }
}
