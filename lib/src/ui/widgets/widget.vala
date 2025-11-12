namespace Tuner {

    /**
     * Base class for creating widgets with bindings
     * It will not be added to widget tree directly
     * Instead it will create widget inside {@link Widget.create}
     * method and bind it with {@link Widget.binding}.
     */
    public abstract class Widget : Item {
        protected Gtk.Widget _native_widget;

        /**
         * Cached Gtk widget that will be used in UI
         */
        public virtual Gtk.Widget native_widget {
            get {
                if (_native_widget == null) {
                    _native_widget = create();

                    if (_native_widget != null && binding != null && binding.validator != null)
                        binding.validator.apply(binding, _native_widget);
                }

                return _native_widget;
            }
        }
        public virtual Tuner.Binding? binding { get; set; }

        public abstract Gtk.Widget? create();
    }
}
