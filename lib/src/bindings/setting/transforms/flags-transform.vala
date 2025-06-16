namespace Tuner {

    /**
     * {@link SettingTransfrom} that will add or remove string array
     * member depending on target's bool value
     * {@link FlagsTransform.value} will be added or removed from array
     */
    public class FlagsTransform : SettingTransform {
        public bool inverse { get; set; }
        public string value { get; set; }

        public override bool is_default() {
            if (value in settings.get_default_value(schema_key).get_strv())
                return value in settings.get_strv(schema_key);

            return !(value in settings.get_strv(schema_key));
        }

        public override bool try_set(Value value) {
            if (expected_type.is_a(typeof(string[])) && value.holds(Type.BOOLEAN)) {
                var flags = new Gee.ArrayList<string>.wrap(settings.get_strv(schema_key));

                if (this.value in flags) flags.remove(this.value);

                if (inverse ? !value.get_boolean() : value.get_boolean())
                    flags.add(this.value);

                settings.set_strv(schema_key, flags.to_array().copy());
                return true;
            }

            return false;
        }

        public override bool try_get(ref Value value, GLib.Variant variant) {
            if (variant.is_of_type(VariantType.STRING_ARRAY) && value.holds(Type.BOOLEAN)) {
                var contains = this.value in variant.get_strv();
                value.set_boolean(inverse ? !contains : contains);
                return true;
            }

            return false;
        }

        public override bool try_reset() {
            if (value in settings.get_default_value(schema_key).get_strv())
                try_set(true);
            else
                try_set(false);

            return true;
        }
    }
}
