using Tuner;

public static void test_is_directory() {
    var tmp_dir = DirUtils.mkdtemp("/tmp/fileutil_test_XXXXXX");
    var tmp_file = Path.build_filename(tmp_dir, "test_file");

    // Create a regular file using GLib.GLib.File
    var file_to_create = GLib.File.new_for_path(tmp_file);
    file_to_create.create(GLib.FileCreateFlags.NONE, null).close();

    // Directory
    var dir_file = GLib.File.new_for_path(tmp_dir);
    assert(FileUtil.is_directory(dir_file) == true);

    // Regular file
    var regular_file = GLib.File.new_for_path(tmp_file);
    assert(FileUtil.is_directory(regular_file) == false);

    // Non‑existent file
    var non_existent = GLib.File.new_for_path(Path.build_filename(tmp_dir, "does_not_exist"));
    assert(FileUtil.is_directory(non_existent) == false);

    file_to_create.delete();
    GLib.File.new_for_path(tmp_dir).delete();
}

public static void test_contains() {
    var tmp_dir = DirUtils.mkdtemp("/tmp/fileutil_test_XXXXXX");
    var existing_name = "present.txt";
    var existing_path = Path.build_filename(tmp_dir, existing_name);
    var file_to_create = GLib.File.new_for_path(existing_path);
    file_to_create.create(GLib.FileCreateFlags.NONE, null).close();

    var dir_file = GLib.File.new_for_path(tmp_dir);
    assert(FileUtil.contains(dir_file, existing_name) == true);
    assert(FileUtil.contains(dir_file, "absent.txt") == false);

    // Not a directory
    var not_dir = GLib.File.new_for_path(existing_path);
    assert(FileUtil.contains(not_dir, existing_name) == false);

    file_to_create.delete();
    GLib.File.new_for_path(tmp_dir).delete();
}

public static void test_get_resource_dirs() {
    string[] dirs = FileUtil.get_resource_dirs("myapp");

    // Must contain at least user data dir and home/.myapp
    assert(dirs.length >= 2);
    assert(Path.build_filename(Environment.get_user_data_dir(), "myapp") in dirs);
    assert(Path.build_filename(Environment.get_home_dir(), ".myapp") in dirs);
}

public static void test_walk_dirs() {
    string base_file = DirUtils.mkdtemp("/tmp/fileutil_walk_XXXXXX");
    string dir1 = Path.build_filename(base_file, "dir1");
    string dir2 = Path.build_filename(base_file, "dir2");
    DirUtils.create(dir1, 0755);
    DirUtils.create(dir2, 0755);

    // Create files using GLib.GLib.File
    string file_a = Path.build_filename(dir1, "A");
    string file_b = Path.build_filename(dir1, "B");
    string file_c = Path.build_filename(dir2, "A");
    string file_d = Path.build_filename(dir2, "D");

    GLib.File.new_for_path(file_a).create(FileCreateFlags.NONE, null).close();
    GLib.File.new_for_path(file_b).create(FileCreateFlags.NONE, null).close();
    GLib.File.new_for_path(file_c).create(FileCreateFlags.NONE, null).close();
    GLib.File.new_for_path(file_d).create(FileCreateFlags.NONE, null).close();

    // Filter: only files whose name contains 'A' or 'B'
    FileUtil.FilterFunc filter = (file) => {
        string name = file.get_basename();
        return name.has_prefix("A") || name.has_prefix("B");
    };

    string[] dirs_to_walk = { dir1, dir2 };
    string[] result = FileUtil.walk_dirs(dirs_to_walk, filter);

    // Expected unique names: "A", "B"
    assert(result.length == 2);
    assert("A" in result);
    assert("B" in result);

    // Non‑existent directory – should be skipped (only a warning, no crash)
    string[] with_bad = { dir1, "/does/not/exist", dir2 };
    result = FileUtil.walk_dirs(with_bad, filter);
    assert(result.length == 2);
    assert("A" in result);
    assert("B" in result);

    GLib.File.new_for_path(file_a).delete();
    GLib.File.new_for_path(file_b).delete();
    GLib.File.new_for_path(file_c).delete();
    GLib.File.new_for_path(file_d).delete();
    GLib.File.new_for_path(dir1).delete();
    GLib.File.new_for_path(dir2).delete();
    GLib.File.new_for_path(base_file).delete();
}

public static void test_expand_home() {
    string home = Environment.get_home_dir();

    assert(FileUtil.expand_home("~/file.txt") == Path.build_filename(home, "file.txt"));
    assert(FileUtil.expand_home("~user/file.txt") == home + "user/file.txt");
    assert(FileUtil.expand_home("/absolute/path") == "/absolute/path");
    assert(FileUtil.expand_home("relative/path") == "relative/path");
    assert(FileUtil.expand_home("~") == home);
}

public static int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/tuner/fileutil/is_directory", test_is_directory);
    Test.add_func("/tuner/fileutil/contains", test_contains);
    Test.add_func("/tuner/fileutil/get_resource_dirs", test_get_resource_dirs);
    Test.add_func("/tuner/fileutil/walk_dirs", test_walk_dirs);
    Test.add_func("/tuner/fileutil/expand_home", test_expand_home);

    return Test.run();
}
