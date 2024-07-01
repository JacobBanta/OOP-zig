const std = @import("std");
const OOP = @import("OOP.zig");

pub fn main() !void {
    std.debug.print("run `zig build test` to run the tests\n", .{});
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
