namespace Tuner {

    /**
     * GSettings binding backend
     */
    public class Setting : Tuner.Binding {
        private Type _expected_type = Type.INVALID;
        private Settings? settings;

        public override GLib.Type expected_type {
            get {
                init();
                return _expected_type;
            }
        }
        public override bool has_default { get; set; default = true; }
        public override bool is_default {
            get {
                init();

                if (settings == null)
                    return true;

                if (transform != null)
                    return transform.is_default();

                return settings.get_value(schema_key).equal(settings.get_default_value(schema_key));
            }
        }

        public string? schema_id { get; set; }
        public string? schema_key { get; set; }
        public SettingTransform? transform { get; set; }

        public override bool get_value(ref Value value) {
            init();

            if (settings != null) {
                var variant = settings.get_value(schema_key);

                if (variant != null) {
                    // Try apply transform first
                    if (transform != null && transform.try_get(ref value, variant)) return true;

                    return convert_to_value(ref value, variant);
                }
            }

            return false;
        }

        public override void set_value(Value value) {
            init();

            if (settings != null) {
                // Try apply transform first
                if (transform != null && transform.try_set(value)) return;

                var new_value = convert_from_value(value, to_variant_type(expected_type));
                var old_value = settings.get_value(schema_key);

                if (new_value != null && old_value != null && !new_value.equal(old_value))
                    settings.set_value(schema_key, new_value);
            }
        }

        public override Gtk.Adjustment? create_adjustment() {
            if (schema_id == null || schema_key == null)
                return null;

            var source = SettingsSchemaSource.get_default();
            var schema = source.lookup(schema_id, true);
            var range = schema.get_key(schema_key).get_range();

            string type;
            Variant values;
            range.get("(sv)", out type, out values);

            VariantIter iter = null;

            if (type != "range" || (iter = values.iterator()).n_children() != 2)
                return null;

            var lower_value = iter.next_value();
            var upper_value = iter.next_value();

            var lower = variant_to_double(lower_value);
            var upper = variant_to_double(upper_value);

            var step_increment = 1.0;
            var page_increment = 10.0;

            if (lower_value.is_of_type(VariantType.DOUBLE)) {
                double distance = Math.fabs(upper - lower);

                if (distance <= 1.0) {
                    step_increment = 0.05;
                    page_increment = 0.2;
                } else if (distance <= 50.0) {
                    step_increment = 0.1;
                    page_increment = 1;
                }
            }

            return new Gtk.Adjustment(0, lower, upper, step_increment, page_increment, 0);
        }

        public override void reset() {
            if (transform != null && transform.try_reset())
                return;

            settings.reset(schema_key);
        }

        public override void changed() {
            base.changed();
            notify_property("is-default");
        }

        private void init() {
            if (schema_id == null || schema_key == null || settings != null)
                return;

            var source = SettingsSchemaSource.get_default();
            var schema = source.lookup(schema_id, true);

            if (schema == null || !schema.has_key(schema_key))
                return;

            settings = new Settings(schema_id);
            _expected_type = from_variant_type(schema.get_key(schema_key).get_value_type());

            if (transform != null)
                transform.init(settings, schema_key, _expected_type);

            settings.changed[schema_key].connect(emit_changed);
        }
    }
}
