namespace Tuner {

    public enum SimpleValidationType {
        SENSITIVITY,
        VISIBILITY;
    }

    public class SimpleValidator : Validator {
        public SimpleValidationType method { get; set; default = SENSITIVITY; }

        public override void apply(Binding binding, Gtk.Widget native_widget) {
            if (method == SENSITIVITY)
                native_widget.sensitive = binding.is_valid();
            else
                native_widget.visible = binding.is_valid();
        }
    }
}
