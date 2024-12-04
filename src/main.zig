const std = @import("std");
// const day_one = @import("day_one/day_one.zig");
// const day_two = @import("day_two/day_two.zig");
// const day_three = @import("03_day_three/day_three.zig");
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

    // try day_one.execute_day_one(&allocator);
    // try day_three.execute_day_three(&allocator);
    try day_four.execute(allocator);

    const endTime = std.time.milliTimestamp();

    std.debug.print("\nTotal Time: {d}", .{endTime - firstTime});
}
