namespace Tuner {

    public class FileContent : Binding {
        public string path { get; set; }
        public override Type expected_type { get { return Type.STRING; } }

        public override bool get_value(ref Value value) {
            try {
                string content;

                if (FileUtils.get_contents(FileUtil.expand_home(path), out content)) {
                    value.set_string(content);
                    return true;
                }
            } catch (Error e) {
                warning("Error: %s\n", e.message);
            }

            return false;
        }

        public override void set_value(Value value) {
            try {
                FileUtils.set_contents(FileUtil.expand_home(path), value.get_string());
            } catch (Error e) {
                warning("Error creating/writing file: %s", e.message);
            }
        }
    }
}
