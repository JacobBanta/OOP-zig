const std = @import("std");

const OOP = struct {
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
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    const foo = struct {
        bar: u32 = undefined,
        baz: u32 = 42,
    };

    const bar = OOP.createClass(struct {
        comptime parent: type = foo,
        bar: u32 = 1,
    });

    try std.testing.expect((foo{}).baz == (bar{}).baz);
    try std.testing.expect((foo{}).bar != (bar{}).bar);
    try std.testing.expect((bar{}).bar == 1);
}

test "functions" {
    const foo = struct {
        bar: u32 = undefined,
        baz: u32 = 42,
        pub fn add(num1: u32, num2: u32) u32 {
            return @addWithOverflow(num1, num2)[0];
        }
    };
    const bar = OOP.createClass(struct {
        comptime parent: type = foo,
        bar: u32 = 1,
    });
    try std.testing.expect((bar{}).add(1, 2) == 3);
}
