namespace Tuner {

    public static Type from_variant_type(VariantType? type) {
        if (type == null)
            return Type.INVALID;

        if (type.equal(VariantType.BOOLEAN))
            return Type.BOOLEAN;
        else if (type.equal(VariantType.BYTE))
            return Type.UCHAR;
        else if (type.equal(VariantType.DOUBLE))
            return Type.DOUBLE;
        else if (type.equal(VariantType.INT32))
            return Type.INT;
        else if (type.equal(VariantType.INT64))
            return Type.INT64;
        else if (type.equal(VariantType.STRING))
            return Type.STRING;
        else if (type.equal(VariantType.STRING_ARRAY))
            return typeof(string[]);
        else if (type.equal(VariantType.UINT32))
            return Type.UINT;
        else if (type.equal(VariantType.UINT64))
            return Type.UINT64;
        else if (type.equal(VariantType.VARIANT))
            return Type.VARIANT;

        return Type.INVALID;
    }

    public static VariantType? to_variant_type(Type type) {
        if (type == Type.INVALID)
            return null;

        if (type.is_a(Type.BOOLEAN))
            return VariantType.BOOLEAN;
        else if (type.is_a(Type.UCHAR))
            return VariantType.BYTE;
        else if (type.is_a(Type.DOUBLE))
            return VariantType.DOUBLE;
        else if (type.is_a(Type.INT))
            return VariantType.INT32;
        else if (type.is_a(Type.INT64))
            return VariantType.INT64;
        else if (type.is_a(Type.STRING))
            return VariantType.STRING;
        else if (type.is_a(typeof(string[])))
            return VariantType.STRING_ARRAY;
        else if (type.is_a(Type.UINT))
            return VariantType.UINT32;
        else if (type.is_a(Type.UINT64))
            return VariantType.UINT64;
        else if (type.is_a(Type.VARIANT))
            return VariantType.VARIANT;

        return null;
    }

    public static double variant_to_double(Variant variant) {
        if (variant.is_of_type(VariantType.DOUBLE))
            return variant.get_double();

        else if (variant.is_of_type(VariantType.INT16))
            return variant.get_int16();
        else if (variant.is_of_type(VariantType.UINT16))
            return variant.get_uint16();

        else if (variant.is_of_type(VariantType.INT32))
            return variant.get_int32();
        else if (variant.is_of_type(VariantType.UINT32))
            return variant.get_uint32();

        else if (variant.is_of_type(VariantType.INT64))
            return variant.get_int64();
        else if (variant.is_of_type(VariantType.UINT64))
            return variant.get_uint64();

        return 0;
    }

    public static Variant? convert_from_value(Value value, VariantType expected_type) {
        if (value.holds(Type.BOOLEAN) && expected_type.equal(VariantType.BOOLEAN))
            return new Variant.boolean(value.get_boolean());
        else if ((value.holds(Type.CHAR) || value.holds(Type.UCHAR)) && expected_type.equal(VariantType.BYTE)) {
            if (value.holds(Type.CHAR))
                return new Variant.byte(value.get_schar());
            else
                return new Variant.byte(value.get_uchar());
        } else if (value.holds(Type.INT) || value.holds(Type.INT64))
            return convert_from_int(value, expected_type);
        else if (value.holds(Type.DOUBLE) || value.holds(Type.FLOAT))
            return convert_from_float(value, expected_type);
        else if (value.holds(Type.UINT) || value.holds(Type.UINT64))
            return convert_from_uint(value, expected_type);
        else if (value.holds(Type.STRING)) {
            if (value.get_string() == null)
                return null;
            else if (expected_type.equal(VariantType.STRING))
                return new Variant.string(value.get_string());
            else if (expected_type.equal(VariantType.BYTESTRING))
                return new Variant.bytestring(value.get_string());
            else if (expected_type.equal(VariantType.OBJECT_PATH))
                return new Variant.object_path(value.get_string());
            else if (expected_type.equal(VariantType.SIGNATURE))
                return new Variant.signature(value.get_string());
        } else if (value.holds(typeof(string[]))) {
            if (value.get_boxed() == null)
                return null;
            return new Variant.strv((string[]) value.get_boxed());
        } else if (value.holds(Type.ENUM)) {
            unowned var eclass = (EnumClass) value.type().class_peek();
            var evalue = eclass.get_value(value.get_enum());

            if (evalue != null)
                return new Variant.string(evalue.value_nick);
            else
                return null;
        } else if (value.holds(Type.FLAGS)) {
            unowned var fclass = (FlagsClass) value.type().class_peek();
            var flags = value.get_flags();
            var builder = new VariantBuilder(new VariantType("as"));
            while (flags != 0) {
                var fvalue = fclass.get_first_value(flags);

                if (fvalue == null)
                    return null;

                builder.add("s", fvalue.value_nick);
                flags &= ~fvalue.value;
            }

            return builder.end();
        }

        critical(@"No GSettings bind handler for type '$(expected_type.dup_string())'.");
        return null;
    }

    public static Variant? convert_from_uint(Value value, VariantType expected_type) {
        uint64 u;

        if (value.holds(Type.UINT))
            u = value.get_uint();
        else if (value.holds(Type.UINT64))
            u = value.get_uint64();
        else
            return null;

        if (expected_type.equal(VariantType.INT16)) {
            if (u <= int16.MAX)
                return new Variant.int16((int16) u);
        } else if (expected_type.equal(VariantType.UINT16)) {
            if (u <= uint16.MAX)
                return new Variant.uint16((uint16) u);
        } else if (expected_type.equal(VariantType.INT32)) {
            if (u <= int.MAX)
                return new Variant.int32((int) u);
        } else if (expected_type.equal(VariantType.UINT32)) {
            if (u <= uint.MAX)
                return new Variant.uint32((uint) u);
        } else if (expected_type.equal(VariantType.INT64)) {
            if (u <= int64.MAX)
                return new Variant.int64((int64) u);
        } else if (expected_type.equal(VariantType.UINT64)) {
            if (u <= uint64.MAX)
                return new Variant.uint64(u);
        } else if (expected_type.equal(VariantType.HANDLE)) {
            if (u <= uint.MAX)
                return new Variant.handle((int) u);
        } else if (expected_type.equal(VariantType.DOUBLE))
            return new Variant.double(u);

        return null;
    }

    public static Variant? convert_from_float(Value value, VariantType expected_type) {
        double d;

        if (value.holds(Type.DOUBLE))
            d = value.get_double();
        else if (value.holds(Type.FLOAT))
            d = value.get_float();
        else
            return null;

        var l = (int64) d;

        if (expected_type.equal(VariantType.INT16)) {
            if (int16.MIN <= l && l <= int16.MAX)
                return new Variant.int16((int16) l);
        } else if (expected_type.equal(VariantType.UINT16)) {
            if (0 <= l && l <= uint16.MAX)
                return new Variant.uint16((uint16) l);
        } else if (expected_type.equal(VariantType.INT32)) {
            if (int.MIN <= l && l <= int.MAX)
                return new Variant.int32((int) l);
        } else if (expected_type.equal(VariantType.UINT32)) {
            if (0 <= l && l <= uint.MAX)
                return new Variant.uint32((uint) l);
        } else if (expected_type.equal(VariantType.INT64)) {
            if (int64.MIN <= l && l <= int64.MAX)
                return new Variant.int64(l);
        } else if (expected_type.equal(VariantType.UINT64)) {
            if (0 <= l && l <= uint64.MAX)
                return new Variant.uint64((uint64) l);
        } else if (expected_type.equal(VariantType.HANDLE)) {
            if (0 <= l && l <= uint.MAX)
                return new Variant.handle((int) l);
        } else if (expected_type.equal(VariantType.DOUBLE))
            return new Variant.double(d);

        return null;
    }

    public static Variant? convert_from_int(Value value, VariantType expected_type) {
        int64 l;

        if (value.holds(Type.INT))
            l = value.get_int();
        else if (value.holds(Type.INT64))
            l = value.get_int64();
        else
            return null;

        if (expected_type.equal(VariantType.INT16)) {
            if (int16.MIN <= l && l <= int16.MAX)
                return new Variant.int16((int16) l);
        } else if (expected_type.equal(VariantType.UINT16)) {
            if (0 <= l && l <= uint16.MAX)
                return new Variant.uint16((uint16) l);
        } else if (expected_type.equal(VariantType.INT32)) {
            if (int.MIN <= l && l <= int.MAX)
                return new Variant.int32((int) l);
        } else if (expected_type.equal(VariantType.UINT32)) {
            if (0 <= l && l <= uint.MAX)
                return new Variant.uint32((uint) l);
        } else if (expected_type.equal(VariantType.INT64)) {
            if (int64.MIN <= l && l <= int64.MAX)
                return new Variant.int64(l);
        } else if (expected_type.equal(VariantType.UINT64)) {
            if (0 <= l && l <= uint64.MAX)
                return new Variant.uint64((uint64) l);
        } else if (expected_type.equal(VariantType.HANDLE)) {
            if (0 <= l && l <= uint.MAX)
                return new Variant.handle((int) l);
        } else if (expected_type.equal(VariantType.DOUBLE))
            return new Variant.double(l);

        return null;
    }

    public static bool convert_to_value(ref Value value, Variant variant) {
        if (variant.is_of_type(GLib.VariantType.BOOLEAN)) {
            if (!value.holds(Type.BOOLEAN))
                return false;

            value.set_boolean(variant.get_boolean());
            return true;
        } else if (
            variant.is_of_type(VariantType.INT16) ||
            variant.is_of_type(VariantType.INT32) ||
            variant.is_of_type(VariantType.INT64)
        ) return convert_to_int(ref value, variant);
        else if (variant.is_of_type(VariantType.DOUBLE))
            return convert_to_float(ref value, variant);
        else if (
            variant.is_of_type(VariantType.UINT16) ||
            variant.is_of_type(VariantType.UINT32) ||
            variant.is_of_type(VariantType.UINT64) ||
            variant.is_of_type(VariantType.HANDLE)
        ) return convert_to_uint(ref value, variant);
        else if (
            variant.is_of_type(VariantType.STRING) ||
            variant.is_of_type(VariantType.OBJECT_PATH) ||
            variant.is_of_type(VariantType.SIGNATURE)
        ) {
            if (value.holds(Type.STRING)) {
                value.set_string(variant.get_string());
                return true;
            } else if (value.holds(Type.ENUM)) {
                unowned var eclass = (EnumClass) value.type().class_peek();
                var nick = variant.get_string();
                var evalue = eclass.get_value_by_nick(nick);

                if (evalue != null) {
                    value.set_enum(evalue.value);
                    return true;
                }

                warning(@"Unable to look up enum nick '$nick' via GType");
                return false;
            }
        } else if (variant.is_of_type(new VariantType("as"))) {
            if (value.holds(typeof(string[]))) {
                value.take_boxed(variant.dup_strv());
                return true;
            } else if (value.holds(Type.FLAGS)) {
                unowned var fclass = (FlagsClass) value.type().class_peek();
                var iter = variant.iterator();
                string nick;
                uint flags = 0;

                while (iter.next("&s", out nick)) {
                    var fvalue = fclass.get_value_by_nick(nick);

                    if (fvalue != null)
                        flags |= fvalue.value;
                    else {
                        warning(@"Unable to lookup flags nick '$nick' via GType");
                        return false;
                    }
                }

                value.set_flags(flags);
                return true;
            }
        } else if (variant.is_of_type(VariantType.BYTESTRING)) {
            value.set_string(variant.get_bytestring());
            return true;
        }

        critical(@"No GSettings bind handler for type '$(variant.get_type_string())'.");
        return false;
    }

    public static bool convert_to_int(ref Value value, Variant variant) {
        int64 l;

        if (variant.is_of_type(VariantType.INT16))
            l = variant.get_int16();
        else if (variant.is_of_type(VariantType.INT32))
            l = variant.get_int32();
        else if (variant.is_of_type(VariantType.INT64))
            l = variant.get_int64();
        else
            return false;

        if (value.holds(Type.INT)) {
            value.set_int((int) l);
            return (int.MIN <= l && l <= int.MAX);
        } else if (value.holds(Type.UINT)) {
            value.set_uint((uint) l);
            return (0 <= l && l <= uint.MAX);
        } else if (value.holds(Type.INT64)) {
            value.set_int64(l);
            return (int64.MIN <= l && l <= int64.MAX);
        } else if (value.holds(Type.UINT64)) {
            value.set_uint64(l);
            return (0 <= l && l <= uint64.MAX);
        } else if (value.holds(Type.DOUBLE)) {
            value.set_double(l);
            return true;
        }

        return false;
    }

    public static bool convert_to_uint(ref Value value, Variant variant) {
        uint64 u;

        if (variant.is_of_type(VariantType.UINT16))
            u = variant.get_uint16();
        else if (variant.is_of_type(VariantType.UINT32))
            u = variant.get_uint32();
        else if (variant.is_of_type(VariantType.UINT64))
            u = variant.get_uint64();
        else if (variant.is_of_type(VariantType.HANDLE))
            u = variant.get_handle();
        else
            return false;

        if (value.holds(Type.INT)) {
            value.set_int((int) u);
            return u <= int.MAX;
        } else if (value.holds(Type.UINT)) {
            value.set_uint((uint) u);
            return u <= uint.MAX;
        } else if (value.holds(Type.INT64)) {
            value.set_int64((int64) u);
            return u <= int64.MAX;
        } else if (value.holds(Type.UINT64)) {
            value.set_uint64(u);
            return u <= uint64.MAX;
        } else if (value.holds(Type.DOUBLE)) {
            value.set_double(u);
            return true;
        }

        return false;
    }

    public static bool convert_to_float(ref Value value, Variant variant) {
        double d;

        if (variant.is_of_type(VariantType.DOUBLE))
            d = variant.get_double();
        else return false;

        var l = (int64) d;

        if (value.holds(Type.INT)) {
            value.set_int((int) l);
            return (int.MIN <= l && l <= int.MAX);
        } else if (value.holds(Type.UINT)) {
            value.set_uint((uint) l);
            return (0 <= l && l <= uint.MAX);
        } else if (value.holds(Type.INT64)) {
            value.set_int64(l);
            return (int64.MIN <= l && l <= int64.MAX);
        } else if (value.holds(Type.UINT64)) {
            value.set_uint64(l);
            return (0 <= l && l <= uint64.MAX);
        } else if (value.holds(Type.DOUBLE)) {
            value.set_double(d);
            return true;
        }

        return false;
    }
}
