# OOP-zig

Bringing OOP into the Zig programming language without vtables.

## Features

### Inheritance and Polymorphism

Child classes are able to inherit and modify fields and functions\* from parent classes.

Functions that implement the `self` parameter do not work properly.

## Installation

First, run the following:

```
zig fetch --save https://github.com/JacobBanta/OOP-zig/archive/30b5e6dc3fc4cd2fa4047fb913a7c1fcc086a9ba.tar.gz
```

Then add the following to `build.zig`:

```zig
const OOP = b.dependency("OOP-zig", .{});
exe.root_module.addImport("OOP", OOP.module("OOP"));
```

## Usage

The basic usage of this library is calling `OOP.createClass()` with a struct that has the field `comptime parent: type = ParentType`

```zig
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
```

## TODO

 - Add a way to cast between types
 - Improve function support
 - Add better documentation
