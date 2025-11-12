namespace Tuner {

    public abstract class Validator : Object {
        public abstract void apply(Binding binding, Gtk.Widget native_widget);
    }
}
