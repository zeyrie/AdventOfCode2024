const std = @import("std");
const get_lev = @import("get_level.zig");
const safe_check = @import("safe_check.zig");

pub fn execute_day_two(alloc: *std.mem.Allocator) !void {
    var arena_allocator = std.heap.ArenaAllocator.init(alloc.*);
    var arena = arena_allocator.allocator();

    defer arena_allocator.deinit();

    var lev: []get_lev.Level = undefined;

    if (try get_lev.get_level(&arena)) |l| {
        lev = l;
    } else {
        return error.FoundNullLocations;
    }

    const safe_levels = try safe_check.get_num_of_safe_levels(&arena);

    std.debug.print("Safe levels are: {d}", .{safe_levels});
}
