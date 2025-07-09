namespace Tuner {

    /**
     * Abstract class for creating custom transform
     */
    public abstract class SettingTransform : Object {
        public Settings settings { get; set; }
        public string schema_key { get; set; }
        public Type expected_type { get; set; }

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
