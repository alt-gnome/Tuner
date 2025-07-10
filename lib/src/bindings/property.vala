namespace Tuner {

    public class Property : Binding {
        private ParamSpec pspec;

        public unowned Object object { set; get; }
        public string name { get; set; }
        public override Type expected_type {
            get {
                init();

                if (pspec != null)
                    return pspec.value_type;

                return Type.INVALID;
            }
        }
        public override bool is_default { get { return true; } }
        public override bool has_default { get { return false; } set {} }

        public override bool get_value(ref Value value) {
            init();

            if (object != null)
                object.get_property(name, ref value);

            return object != null;
        }
        public override void set_value(Value value) {
            init();

            if (object != null)
                object.set_property(name, value);
        }

        private void init() {
            if (pspec == null) {
                pspec = object.get_class().find_property(name);
                
                if (pspec == null)
                    critical(@"Object $(object.get_type().name()) has no property named $name");
                else
                    object.notify[name].connect(() => changed());
            }
        }
    }
}
