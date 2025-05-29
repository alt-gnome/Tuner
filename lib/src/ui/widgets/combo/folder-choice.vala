using Gee;

namespace Tuner {

    public class FolderChoice : ChoiceLoader {
        public string lookup_dir { get; set; }
        public string content_filter { get; set; }

        public override void load(ListStore model) {
            var dirs = FileUtil.walk_dirs(FileUtil.get_resource_dirs(lookup_dir), file => FileUtil.contains(file, content_filter));
            var original = new ArrayList<string>.wrap(dirs);
            original.sort();

            foreach (var item in original) {
                model.append(new Choice() {
                    title = item,
                    value = new Variant.string(item)
                });
            }
        }
    }
}
