namespace Tuner {

    internal class FileUtil {

        public static bool is_directory(GLib.File file) {
            return file.query_file_type(FileQueryInfoFlags.NONE) == FileType.DIRECTORY;
        }

        public static bool contains(GLib.File directory, string name) {
            return is_directory(directory) && GLib.File.new_for_path(Path.build_filename(directory.get_path(), name)).query_exists();
        }

        public static string[] get_resource_dirs(string resource) {
            string[] dirs = {};

            foreach (var dir in Environment.get_system_data_dirs())
                dirs += Path.build_filename(dir, resource);

            dirs += Path.build_filename(Environment.get_user_data_dir(), resource);
            dirs += Path.build_filename(Environment.get_home_dir(), "." + resource);

            return dirs;
        }

        public static string[] walk_dirs(string[] dirs, FilterFunc filter) {
            string[] valid = {};

            foreach (var dir in dirs) {
                try {
                    var file = GLib.File.new_for_path(dir);

                    if (file.query_file_type(FileQueryInfoFlags.NONE) == FileType.DIRECTORY) {
                        var directory = Dir.open(file.get_path(), 0);

                        string? name = null;
                        while ((name = directory.read_name()) != null) {
                            var found = GLib.File.new_for_path(Path.build_filename(dir, name));
                            if (filter(found) && !(name in valid))
                                valid += name;
                        }
                    }
                } catch (Error e) {
                    warning(@"Error while walking directories: $(e.message)");
                }
            }

            return valid;
        }

        public delegate bool FilterFunc(GLib.File file);
    }
}
