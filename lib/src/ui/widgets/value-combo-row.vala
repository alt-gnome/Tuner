using Gee;

namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/value-combo-row.ui")]
    public class ValueComboRow : ComboRow, Modifier {
        [GtkChild]
        private unowned Gtk.Revealer revealer;
        [GtkChild]
        private unowned Gtk.Button reset_button;

        public override void key_found() {
            var variant = schema.get_key(key).get_range();

            string range_type;
            Variant arr;
            variant.get("(sv)", out range_type, out arr);
            
            if (range_type != "enum") {
                is_valid_setting = false;

                warning(@"Key \"$key\" does not exists. Skipping");
                return;
            }
            original = new ArrayList<string>.wrap(arr.get_strv());
            original.sort();

            update_model();
            selected = original.index_of(settings.get_string(key));
            
            bind_property("is-default", reset_button, "sensitive", BindingFlags.SYNC_CREATE);

            update_is_default();
            notify["selected"].connect(on_selected);
            
            setup_separator_revealer(revealer, reset_button);
        }

        [GtkCallback]
        public new void on_reset() {
            base.on_reset();
        }

        private void update_model() {
            string[] final = {};

            foreach (var str in original)
                final += title_case(str);

            model = new Gtk.StringList(final);
        }

        private string title_case(string str) {
            var builder = new StringBuilder();

            bool up_next = true;
            for (int i = 0; i < str.char_count(); i++) {
                var ch = str.get_char(str.index_of_nth_char(i)).to_string();
                
                if (ch == "-") {
                    up_next = true;
                    ch = " ";
                } else if (up_next) {
                    ch = ch.up();
                    up_next = false;
                }

                builder.append(ch);
            }

            return builder.str;
        }
    }
}
