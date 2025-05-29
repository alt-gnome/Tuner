namespace Tuner {

    public class ValueTransform : SettingTransform {
        public string value { get; set; }

        public override bool is_default() {
            if (expected_type.is_a(Type.STRING)) {
                return settings.get_string(schema_key) != value;
            }
            return true;
        }

        public override bool try_get(ref GLib.Value value, GLib.Variant variant) {
            if (variant.is_of_type(VariantType.STRING) && value.holds(Type.BOOLEAN)) {
                value.set_boolean(variant.dup_string() == this.value);
                return true;
            }
            return false;
        }

        public override bool try_set(GLib.Value value) {
            if (expected_type.is_a(Type.STRING) && value.holds(Type.BOOLEAN)) {
                if (value.get_boolean())
                    settings.set_string(schema_key, this.value);
                else
                    settings.reset(schema_key);
                return true;
            }
            return false;
        }
    }
}
