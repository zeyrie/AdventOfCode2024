const std = @import("std");
// const day_one = @import("day_one/day_one.zig");
const day_two = @import("day_two/day_two.zig");

pub fn main() !void {
    const firstTime = std.time.milliTimestamp();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leaked", .{});
        }
    }

    // try day_one.execute_day_one(&allocator);
    try day_two.execute_day_two(&allocator);

    const endTime = std.time.milliTimestamp();

    std.debug.print("\nTotal Time: {d}", .{endTime - firstTime});
}
