namespace Tuner {

    /**
     * Abstract class for creating custom binding backend
     */
    public abstract class Binding : Object {
        private Object? instance;
        private ParamSpec? pspec;
        private int inhibit_counter;
        private ulong? instance_notify_id;

        public abstract bool has_default { get; }
        public abstract bool is_default { get; }
        public abstract Type expected_type { get; }

        public virtual void on_instance_notify() {
            if (inhibit_counter > 0) return;

            var @value = Value(pspec.value_type);
            instance.get_property(pspec.name, ref @value);
            set_value(@value);
        }

        public void inhibit() {
            inhibit_counter++;
        }

        public void uninhibit() {
            if (inhibit_counter > 0)
                inhibit_counter--;
        }

        public void emit_changed() {
            inhibit();
            changed();
            uninhibit();
        }

        public virtual void unbind() {
            if (instance != null) {
                instance.disconnect(instance_notify_id);
                instance_notify_id = null;
                instance = null;
            }

            pspec = null;
        }

        public virtual void bind(Object target, string property_name) {
            unbind();

            pspec = target.get_class().find_property(property_name);
            if (pspec == null) {
                critical(@"Property $property_name not found on $(target.get_type().name())");
                return;
            }

            instance = target;
            instance_notify_id = instance.notify[property_name].connect(() => on_instance_notify());

            emit_changed();
        }

        public virtual Gtk.Adjustment? create_adjustment() {
            return null;
        }

        public virtual void reset() {}

        public abstract bool get_value(ref Value value);
        public abstract void set_value(Value value);

        public virtual signal void changed() {
            if (instance == null || pspec == null || inhibit_counter <= 0) return;

            var value = Value(pspec.value_type);
            if (get_value(ref value)) {
                if (value.holds(Type.STRING)) {
                    var dest = Value(Type.STRING);
                    instance.get_property(pspec.name, ref dest);

                    if (value.get_string() == dest.get_string())
                        return;
                }

                instance.set_property(pspec.name, value);
            }
        }

        public override void dispose() {
            unbind();
            base.dispose();
        }
    }
}
