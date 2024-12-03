const std = @import("std");
const get_loc = @import("get_loc.zig");
const distance = @import("get_distance.zig");
const similarity = @import("get_similarity.zig");

pub fn execute_day_one(alloc: *std.mem.Allocator) !void {
    var loc: get_loc.Locations = undefined;

    if (try get_loc.read_location_ids(alloc)) |l| {
        loc = l;
    } else {
        return error.FoundNullLocations;
    }

    defer alloc.free(loc.left);
    defer alloc.free(loc.right);

    // Sort both the arrays in the file
    std.mem.sort(usize, loc.left, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, loc.right, {}, comptime std.sort.asc(usize));

    try distance.get_total_distance(&loc);
    try similarity.get_similarity_score(&loc);
}
