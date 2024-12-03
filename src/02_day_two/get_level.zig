const std = @import("std");
const builtin = @import("builtin");

pub const Level = struct {
    flr: []u16,
};

pub fn get_level(allocator: *std.mem.Allocator) !?[]Level {
    // const path = "resource/lvl.test";
    const path = "resource/lvl.input";

    std.log.info("Path: {s}", .{path});

    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return null;
    };
    defer file.close();

    var count: u16 = 0;

    var levels = try allocator.alloc(Level, 1000);

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator.*, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read file: {s}", .{@errorName(err)});
        return null;
    }) |line| {
        defer allocator.free(line);

        var ids = std.mem.splitSequence(u8, line, " ");

        var len: u16 = 0;

        while (ids.next()) |_| {
            len += 1;
        }

        ids.reset();

        ids = std.mem.splitSequence(u8, line, " ");

        var index: u16 = 0;
        var flrs = try allocator.alloc(u16, len);

        while (ids.next()) |id| {
            flrs[index] = std.fmt.parseInt(u16, id, 10) catch |err| {
                std.log.err("Unable to convert string to int; Error: {s}", .{@errorName(err)});
                return null;
            };
            index += 1;
        }

        levels[count] = .{ .flr = flrs };

        count += 1;
    }

    return levels;
}

test "get_levels" {
    const alloc = std.testing.allocator;

    var arena_allocator = std.heap.ArenaAllocator.init(alloc);
    var arena = arena_allocator.allocator();

    var lvls: []Level = undefined;

    if (try get_level(&arena)) |l| {
        lvls = l;
    } else {
        try std.testing.expect(false);
    }

    arena_allocator.deinit();

    try std.testing.expect(true);
}
