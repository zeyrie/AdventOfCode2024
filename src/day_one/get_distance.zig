const std = @import("std");
const get_loc = @import("get_loc.zig");
const Locations = get_loc.Locations;

/// Calculate the total distance between the two lists.
pub fn get_total_distance(locations: *Locations) !void {
    const left_arr = locations.left;
    const right_arr = locations.right;

    std.mem.sort(usize, left_arr, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right_arr, {}, comptime std.sort.asc(usize));

    var dis: usize = 0;

    for (left_arr, right_arr) |left, right| {
        if (left < right) {
            const diff = right - left;
            dis += diff;
        } else {
            const diff = left - right;
            dis += diff;
        }
    }

    std.debug.print("Distance: {d}", .{dis});
}
