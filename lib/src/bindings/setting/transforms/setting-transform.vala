namespace Tuner {

    public abstract class SettingTransform : Object {
        protected Settings settings;
        protected string schema_key;
        protected Type expected_type;

        public virtual void init(Settings settings, string schema_key, Type expected_type) {
            this.settings = settings;
            this.schema_key = schema_key;
            this.expected_type = expected_type;
        }

        public abstract bool is_default();
        public abstract bool try_get(ref Value value, Variant variant);
        public abstract bool try_set(Value value);
        public virtual bool try_reset() {
            return false;
        }
    }
}
