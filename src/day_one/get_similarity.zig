const std = @import("std");
const get_loc = @import("get_loc.zig");
const Locations = @import("get_loc.zig").Locations;

pub fn get_similarity_score(locations: *Locations) !void {
    const left_arr = locations.left;
    const right_arr = locations.right;

    var score: usize = 0;

    for (left_arr) |left| {
        var count: usize = 0;

        for (right_arr) |right| {
            if (left == right) {
                count += 1;
            }
        }

        score += count * left;
    }

    std.debug.print("\n\nScore: {d}", .{score});
}
