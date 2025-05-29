namespace Tuner {

    /**
     * Base class for creating widgets with bindings
     * It will not be added to widget tree directly
     * Instead it will create widget inside {@link Widget.create}
     * method and bind it with {@link Widget.binding}.
     */
    public abstract class Widget : Gtk.Widget {
        public virtual Tuner.Binding? binding { get; set; }

        public abstract Gtk.Widget? create();
    }
}
