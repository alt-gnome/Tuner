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

        public static string? read_file(string path) {
            try {
                var file = GLib.File.new_for_path(path);

                if (!file.query_exists()) {
                    return null;
                }

                var dis = new DataInputStream(file.read());
                string line;
                size_t length;
                string result = "";

                while ((line = dis.read_line(out length)) != null)
                    result += @"$line\n";

                if (result.length > 0)
                    result = result.substring(0, result.length - 1);

                return result;
            } catch (Error e) {
                warning("Error: %s\n", e.message);
                return null;
            }
        }

        public static void write_file(string path, string content) {
            try {
                var file = GLib.File.new_for_path(path);
                var parent = file.get_parent();

                if (parent != null && !parent.query_exists()) {
                    parent.make_directory_with_parents();
                }

                if (!file.query_exists())
                    file.create(FileCreateFlags.REPLACE_DESTINATION);

                var dos = new DataOutputStream(file.open_readwrite().output_stream);
                dos.put_string(content);
            } catch (Error e) {
                warning("Error creating/writing file: %s", e.message);
            }
        }

        public delegate bool FilterFunc(GLib.File file);
    }
}
