const std = @import("std");
const day_one = @import("01_day_one/day_one.zig");
const day_two = @import("02_day_two/day_two.zig");
const day_three = @import("03_day_three/day_three.zig");
const day_four = @import("04_day_four/day_four.zig");

pub fn main() !void {
    const firstTime = std.time.milliTimestamp();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leaked", .{});
        }
    }

    std.debug.print("\nDay One\n", .{});
    try day_one.execute(allocator);
    std.debug.print("\n____________________________________\n", .{});
    std.debug.print("\nDay Two\n", .{});
    try day_two.execute(allocator);
    std.debug.print("\n____________________________________\n", .{});
    std.debug.print("\nDay Three\n", .{});
    try day_three.execute(allocator);
    std.debug.print("\n____________________________________\n", .{});
    std.debug.print("\nDay Four\n", .{});
    try day_four.execute(allocator);
    std.debug.print("\n____________________________________\n", .{});

    const endTime = std.time.milliTimestamp();

    std.debug.print("\nTotal Time: {d}", .{endTime - firstTime});
}
