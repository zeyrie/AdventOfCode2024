const std = @import("std");
const get_lev = @import("get_level.zig");
const safe_check = @import("safe_check.zig");

pub fn execute(alloc: std.mem.Allocator) !void {
    var arena_allocator = std.heap.ArenaAllocator.init(alloc);
    const arena = arena_allocator.allocator();

    defer arena_allocator.deinit();

    var lev: []get_lev.Level = undefined;

    if (try get_lev.get_level(arena)) |l| {
        lev = l;
    } else {
        return error.FoundNullLocations;
    }

    std.debug.print("\nPart - I\n", .{});
    var safe_levels = try safe_check.get_safe_count_for(&lev);
    std.debug.print("Safe levels are: {d}\n", .{safe_levels});

    std.debug.print("\nPart - II\n", .{});
    safe_levels = try safe_check.get_safe_count_with_removal(arena, &lev);
    std.debug.print("Safe levels are: {d}\n", .{safe_levels});
}
