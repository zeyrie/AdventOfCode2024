const std = @import("std");

pub fn get_matrix(alloc: std.mem.Allocator) !?[][]const u8 {
    const path = "resource/matrix.input";

    var file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Unable to open file: {any}", .{@errorName(err)});
        return null;
    };
    defer file.close();

    var count: u8 = 0;
    var mat = try alloc.alloc([]const u8, 140);

    while (file.reader().readUntilDelimiterOrEofAlloc(alloc, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Unable to read file: {any}", .{@errorName(err)});
        return null;
    }) |line| {
        mat[count] = line;
        count += 1;
    }

    return mat;
}
