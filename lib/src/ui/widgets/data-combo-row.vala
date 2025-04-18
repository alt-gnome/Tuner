using Gee;

namespace Tuner {

    [GtkTemplate (ui = "/org/altlinux/Tuner/data-combo-row.ui")]
    public class DataComboRow : ComboRow, Modifier {
        private string _lookup_dir;

        [GtkChild]
        private unowned Gtk.Revealer revealer;
        [GtkChild]
        private unowned Gtk.Button reset_button;

        public string content_filter { get; set; }
        public string lookup_dir {
            get { return _lookup_dir; }
            set {
                var dirs = FileUtil.walk_dirs(FileUtil.get_resource_dirs(value), file => FileUtil.contains(file, content_filter));
                original = new ArrayList<string>.wrap(dirs);
                original.sort();

                var model = new Gtk.StringList(null);
                foreach (var item in original) {
                    model.append(item);
                }
                set_model(model);

                _lookup_dir = value;
            }
        }

        [GtkCallback]
        public new void on_reset() {
            base.on_reset();
        }

        public override void key_found() {
            bind_property("is-default", reset_button, "sensitive", BindingFlags.SYNC_CREATE);

            setup_separator_revealer(revealer, reset_button);

            set_selected(original.index_of(settings.get_string(key)));
            update_is_default();
            notify["selected"].connect(on_selected);
        }
    }
}
