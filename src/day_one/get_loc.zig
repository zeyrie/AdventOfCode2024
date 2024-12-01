const std = @import("std");

pub const Locations = struct {
    left: []usize,
    right: []usize,
};

/// read the IDs from the loc.input file in the resources directory
pub fn read_location_ids(allocator: *std.mem.Allocator) !?Locations {
    const path = "resource/loc.input";

    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return null;
    };
    defer file.close();

    var count: u16 = 0;

    var loc: Locations = .{
        .left = try allocator.alloc(usize, 1000),
        .right = try allocator.alloc(usize, 1000),
    };

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator.*, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read file: {s}", .{@errorName(err)});
        return null;
    }) |line| {
        defer allocator.free(line);

        var ids = std.mem.splitSequence(u8, line, "   ");

        loc.left[count] = std.fmt.parseInt(usize, ids.next().?, 10) catch |err| {
            std.log.err("Unable to convert string to int; Error: {s}", .{@errorName(err)});
            return null;
        };

        loc.right[count] = std.fmt.parseInt(usize, ids.next().?, 10) catch |err| {
            std.log.err("Unable to convert string to int; Error: {s}", .{@errorName(err)});
            return null;
        };

        count += 1;
    }

    return loc;
}

test "Get input from file" {
    var alloc = std.testing.allocator;
    const loc = read_location_ids(&alloc) catch null;

    if (loc) |_| {
        try std.testing.expect(true);
    } else {
        try std.testing.expect(false);
    }
}
