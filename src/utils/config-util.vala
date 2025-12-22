using Gee;

namespace Tuner.ConfigUtil {

    public bool import_config(PageList pages, Json.Node node) {
        if (
            node.get_node_type() == Json.NodeType.OBJECT
            && node.get_object().has_member("values")
            && node.get_object().has_member("format")
            && node.get_object().get_string_member("format") == "v1"
        ) {
            foreach (var element in node.get_object().get_array_member("values").get_elements()) {
                var path = element.get_object().get_string_member("path");
                var value_node = element.get_object().get_member("value");
                var widget = pages.get_element_by_path(path) as Widget;

                if (widget != null && widget.binding != null) {
                    var value = Value(widget.binding.expected_type);

                    if (node_to_value(ref value, value_node)) {
                        widget.binding.set_value(value);
                    }
                }
            }
            return true;
        }

        return false;
    }

    public Json.Node? export_config(PageList pages) {
        var widgets = pages.find_widgets_with_path();
        if (widgets.is_empty) return null;

        var builder = new Json.Builder();

        builder.begin_object();
        builder.set_member_name("version");
        builder.add_string_value(VERSION);
        builder.set_member_name("format");
        builder.add_string_value("v1");
        builder.set_member_name("values");
        builder.begin_array();

        foreach (var widget in widgets) {
            if (widget.binding != null) {
                var val = Value(widget.binding.expected_type);
                if (widget.binding.get_value(ref val)) {
                    var node = value_to_node(val);
                    if (node == null) continue;

                    builder.begin_object();
                    
                    builder.set_member_name("path");
                    builder.add_string_value(build_widget_path(widget));

                    builder.set_member_name("value");
                    builder.add_value(node);

                    builder.end_object();
                }
            }
        }

        builder.end_array();
        builder.end_object();

        return builder.get_root();
    }

    private bool node_to_value(ref Value value, Json.Node node) {
        if (node.get_value_type() == Type.BOOLEAN && value.holds(Type.BOOLEAN)) {
            value.set_boolean(node.get_boolean());
            return true;
        } else if (node.get_value_type() == Type.INT64) {
            if (value.holds(Type.INT64)) {
                value.set_int64(node.get_int());
                return true;
            } else if (value.holds(Type.INT)) {
                value.set_int((int) node.get_int());
                return true;
            } else if (value.holds(Type.UINT64)) {
                value.set_uint64(node.get_int());
                return true;
            } else if (value.holds(Type.UINT)) {
                value.set_uint((uint) node.get_int());
            }
        } else if (node.get_value_type() == Type.DOUBLE) {
            if (value.holds(Type.DOUBLE)) {
                value.set_double(node.get_double());
                return true;
            } else if (value.holds(Type.FLOAT)) {
                value.set_float((float) node.get_double());
                return true;
            }
        } else if (node.get_value_type() == Type.STRING) {
            if (value.holds(Type.STRING)) {
                value.set_string(node.get_string());
                return true;
            } else if (value.holds(Type.CHAR)) {
                value.set_schar((int8) node.get_string());
                return true;
            } else if (value.holds(Type.UCHAR)) {
                value.set_uchar((uchar) node.get_string());
                return true;
            }
        }

        return false;
    }

    private Json.Node? value_to_node(Value value) {
        var node = new Json.Node.alloc();

        if (value.holds(Type.BOOLEAN))
            node.init_boolean(value.get_boolean());
        else if (value.holds(Type.CHAR))
            node.init_string(value.get_schar().to_string());
        else if (value.holds(Type.UCHAR))
            node.init_string(value.get_uchar().to_string());
        else if (value.holds(Type.INT))
            node.init_int(value.get_int());
        else if (value.holds(Type.INT64))
            node.init_int(value.get_int64());
        else if (value.holds(Type.DOUBLE))
            node.init_double(value.get_double());
        else if (value.holds(Type.FLOAT))
            node.init_double(value.get_float());
        else if (value.holds(Type.UINT))
            node.init_int(value.get_uint());
        else if (value.holds(Type.UINT64))
            node.init_int((int64) value.get_uint64());
        else if (value.holds(Type.STRING))
            node.init_string(value.get_string());

        if (node.get_node_type() != Json.NodeType.OBJECT)
            return node;

        return null;
    }

    private string build_widget_path(Widget widget) {
        var parent = widget.parent;
        var path = widget.id;

        while (parent != null) {
            path = parent.id + "." + path;
            parent = parent.parent;
        }

        return path;
    }
}
