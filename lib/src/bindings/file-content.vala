namespace Tuner {

    public class FileContent : Binding {
        public string path { get; set; }
        public override Type expected_type { get { return Type.STRING; } }

        public override bool get_value(ref Value value) {
            var content = FileUtil.read_file(path);

            if (content != null) {
                value.set_string(content);

                return true;
            }

            return false;
        }

        public override void set_value(Value value) {
            FileUtil.write_file(path, value.get_string());
        }
    }
}
