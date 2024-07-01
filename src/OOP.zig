const std = @import("std");

pub fn createClass(Type: type) type {
    var ret = struct {};
    if (@hasField(Type, "parent")) {
        const parent = createClass(for (@typeInfo(Type).Struct.fields) |field| {
            if (std.mem.eql(u8, field.name, "parent")) break @as(*type, @ptrCast(@constCast(field.default_value.?))).*;
        });
        for (@typeInfo(parent).Struct.fields ++ @typeInfo(Type).Struct.fields) |field| {
            if (!@hasField(ret, field.name)) {
                const fields = [_]@TypeOf(field){field};
                const retInfo = @typeInfo(ret).Struct;
                ret = @Type(.{ .Struct = .{
                    .layout = retInfo.layout,
                    .backing_integer = retInfo.backing_integer,
                    .fields = retInfo.fields ++ fields,
                    .decls = retInfo.decls,
                    .is_tuple = retInfo.is_tuple,
                } });
            } else if (!std.mem.eql(u8, field.name, "parent")) {
                if (field.type != (for (@typeInfo(ret).Struct.fields) |field_| {
                    if (std.mem.eql(u8, field_.name, field.name)) break field_.type;
                })) {
                    @compileError("Type of field '" ++ field.name ++ "' inconsistent");
                }
                const fields = [_]@TypeOf(field){field};
                var retInfo = @typeInfo(ret).Struct;
                for (retInfo.fields, 0..) |parentField, index| {
                    if (std.mem.eql(u8, parentField.name, field.name)) {
                        //retInfo.fields[index].default_value = field.default_value;
                        ret = @Type(.{ .Struct = .{
                            .layout = retInfo.layout,
                            .backing_integer = retInfo.backing_integer,
                            .fields = retInfo.fields[0..index] ++ fields ++ retInfo.fields[(index + 1)..],
                            .decls = retInfo.decls,
                            .is_tuple = retInfo.is_tuple,
                        } });
                    }
                }
            }
        }
    } else {
        for (@typeInfo(Type).Struct.fields) |field| {
            const fields = [_]@TypeOf(field){field};
            const retInfo = @typeInfo(ret).Struct;
            ret = @Type(.{ .Struct = .{
                .layout = retInfo.layout,
                .backing_integer = retInfo.backing_integer,
                .fields = retInfo.fields ++ fields,
                .decls = retInfo.decls,
                .is_tuple = retInfo.is_tuple,
            } });
        }
    }

    for (@typeInfo(Type).Struct.decls) |decl| {
        const fn_name = decl.name;
        const field = std.builtin.Type.StructField{ .name = fn_name, .type = @TypeOf(@field(Type, decl.name)), .default_value = @field(Type, decl.name), .is_comptime = false, .alignment = @alignOf(@TypeOf(@field(Type, decl.name))) };
        if (!@hasField(ret, field.name)) {
            const fields = [_]@TypeOf(field){field};
            const retInfo = @typeInfo(ret).Struct;
            ret = @Type(.{ .Struct = .{
                .layout = retInfo.layout,
                .backing_integer = retInfo.backing_integer,
                .fields = retInfo.fields ++ fields,
                .decls = retInfo.decls,
                .is_tuple = retInfo.is_tuple,
            } });
        } else {
            if (field.type != (for (@typeInfo(ret).Struct.fields) |field_| {
                if (std.mem.eql(u8, field_.name, field.name)) break field_.type;
            })) {
                @compileError("Type of field '" ++ field.name ++ "' inconsistent");
            }
            const fields = [_]@TypeOf(field){field};
            var retInfo = @typeInfo(ret).Struct;
            for (retInfo.fields, 0..) |parentField, index| {
                if (std.mem.eql(u8, parentField.name, field.name)) {
                    //retInfo.fields[index].default_value = field.default_value;
                    ret = @Type(.{ .Struct = .{
                        .layout = retInfo.layout,
                        .backing_integer = retInfo.backing_integer,
                        .fields = retInfo.fields[0..index] ++ fields ++ retInfo.fields[(index + 1)..],
                        .decls = retInfo.decls,
                        .is_tuple = retInfo.is_tuple,
                    } });
                }
            }
        }
    }

    return ret;
}
