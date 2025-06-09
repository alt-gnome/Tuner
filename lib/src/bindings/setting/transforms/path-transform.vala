namespace Tuner {

    /**
     * {@link SettingTransform} that will transform path depending
     * on values of {@link PathTransform.hide_uri_prefix} and {@link PathTransform.fold_home_path}
     */
    public class PathTransform : SettingTransform {
        /**
         * If true hides file uri prefix from target value
         */
        public bool hide_uri_prefix { get; set; }
        /**
         * If true folds home path to '~' in target value
         */
        public bool fold_home_path { get; set; }

        public override bool is_default() {
            return settings.get_value(schema_key).equal(settings.get_default_value(schema_key));
        }

        public override bool try_set(Value value) {
            if (expected_type.is_a(Type.STRING) && value.holds(Type.STRING)) {
                var result = value.get_string();

                if (fold_home_path)
                    result = result.replace("~", Environment.get_home_dir());

                if (hide_uri_prefix && !result.has_prefix("file://"))
                    result = @"file://$result";

                settings.set_string(schema_key, result);
                return true;
            }
            return false;
        }

        public override bool try_get(ref Value value, Variant variant) {
            if (value.holds(Type.STRING) && variant.is_of_type(VariantType.STRING)) {
                var result = variant.get_string();

                if (hide_uri_prefix)
                    result = result.replace("file://", "");

                if (fold_home_path)
                    result = result.replace(Environment.get_home_dir(), "~");

                value.set_string(result);

                return true;
            }
            return false;
        }
    }
}
