namespace Tuner {

    public class Combo : Widget {
        public string title { get; set; }
        public string subtitle { get; set; }
        public ListStore model;

        construct {
            model = new ListStore(typeof(Choice));
        }

        public override bool accepts(Item item, string? type) {
            return item is Choice || item is ChoiceLoader;
        }

        public override Gtk.Widget? create() {
            if (binding != null) {
                visit_children(visitor);

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

        private VisitResult visitor(Item item) {
            if (item is Choice) {
                model.append((Choice) item);
            } else if (item is ChoiceLoader) {
                var loader = (ChoiceLoader) item;
                loader.load(model);
            }

            return VisitResult.CONTINUE;
        }
    }
}
