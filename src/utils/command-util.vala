using Gee;

namespace Tuner.CommandUtil {

    public int handle_command_line(
        PageList pages,
        ApplicationCommandLine command_line,
        string action
    ) {
        switch (action) {
            case "--help":
            case "-h":
                print("Usage:\n");
                print("  --help           # Show this help\n");
                print("  info <path>      # Query info\n");
                return 0;
            case "info":
                return print_info(pages, command_line);
            case "export":
                var node = ConfigUtil.export_config(pages);
                if (node != null) {
                    print(@"$(Json.to_string(node, false))\n");
                    return 0;
                }
                return 1;
            case "import":
                try {
                    return import(pages, command_line);
                } catch (Error err) {
                    print(@"Failed to import config: $(err.message)\n");
                    return 1;
                }
            default:
                print("Unknown command: %s\n", action);
                return 127;
        }
    }

    private int import(PageList pages, ApplicationCommandLine command_line) throws Error {
        Json.Node? node = null;
        var args = command_line.get_arguments();

        if (args.length > 2) {
            var file = command_line.create_file_for_arg(args[2]);

            if (file.query_exists()) {
                var parser = new Json.Parser();
                parser.load_from_stream(file.read());

                node = parser.get_root();
            } else {
                print("File doesnt exist!\n");
                return 1;
            }
        }

        if (node != null && ConfigUtil.import_config(pages, node))
            return 0;

        print("Failed to import config!\n");
        return 1;
    }

    private int print_info(PageList pages, ApplicationCommandLine command_line) {
        var args = command_line.get_arguments();

        if (args.length < 3) {
            print("Not enough args\n");
            return 1;
        }

        var item = pages.get_element_by_path(args[2]);

        if (item != null) {
            print_item_info(item);
            return 0;
        }

        print("Item not found!\n");
        return 1;
    }

    private void print_item_info(Item item) {
        print(@"$(item.get_type().name()): $(item.id)\n");

        print_string_property(item, "title", "Title");
        print_string_property(item, "description", "Description");
        print_string_property(item, "subtitle", "Subtitle");

        var widget = item as Widget;
        if (widget != null && widget.binding != null) {
            print("Current value: ");
            var val = Value(widget.binding.expected_type);
            if (widget.binding.get_value(ref val)) {
                var str = value_to_string(val);
                if (str != null)
                print(@"$str\n");
            }
        }
    }

    private void print_string_property(Object object, string name, string display_name) {
        if (has_property(object, name, Type.STRING)) {
            Value val = Value(Type.STRING);
            object.get_property(name, ref val);

            if (val.get_string() != null)
                print(@"$display_name: $(val.get_string())\n");
        }
    }

    private bool has_property(Object object, string name, Type type) {
        var pspec = object.get_class().find_property(name);

        return pspec != null && pspec.value_type == type;
    }
}
