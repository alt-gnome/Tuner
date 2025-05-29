namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/combo-row.ui")]
    internal class ComboRow : Adw.ComboRow {
        private bool selecting;

        [GtkChild]
        private unowned ResetButton reset_button;

        public unowned Binding binding { get; set; }

        public ComboRow(Binding binding, ListModel model, int selected) {
            this.binding = binding;
            this.model = model;

            notify["selected"].connect(() => on_selected());

            if (binding != null)
                binding.changed.connect(binding_changed);

            this.selected = selected;

            if (binding.has_default) {
                reset_button.visible = true;
                binding.bind_property("is-default", reset_button, "sensitive", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
            }
        }

        [GtkCallback]
        private void on_reset() {
            binding.reset();
        }

        private void on_selected() {
            if (binding == null || selecting) return;

            selecting = true;
            tooltip_text = null;

            var choice = get_selected_item() as Choice;
            if (choice != null && choice.value != null) {
                tooltip_text = choice.title;

                if (binding.expected_type != Type.INVALID) {
                    var value = Value(binding.expected_type);

                    if (convert_to_value(ref value, choice.value)) {
                        binding.set_value(value);
                    }
                }
            }

            selecting = false;
        }

        private void binding_changed() {
            if (selecting || model.get_n_items() == 0) return;

            var type = binding.expected_type;
            var expected_type = to_variant_type(type);
            var value = Value(type);

            if (!binding.get_value(ref value))
                return;

            var variant = convert_from_value(value, expected_type);

            for (int i = 0; i < model.get_n_items(); i++) {
                var choice = (Choice) model.get_item(i);
                if (choice.value.equal(variant)) {
                    selected = i;
                    break;
                }
            }
        }
    }
}
