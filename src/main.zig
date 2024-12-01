const std = @import("std");
const day_one = @import("day_one/day_one.zig");

pub fn main() !void {
    const firstTime = std.time.milliTimestamp();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leaked", .{});
        }
    }

    try day_one.execute_day_one(&allocator);

    const endTime = std.time.milliTimestamp();

    std.debug.print("\nTotal Time: {d}", .{endTime - firstTime});
}
