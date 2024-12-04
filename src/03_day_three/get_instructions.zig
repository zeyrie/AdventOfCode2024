const std = @import("std");

pub fn get_instructions(allocator: std.mem.Allocator) !?[][]const u8 {
    const path = "resource/corrupt_mul.input";

    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return null;
    };
    defer file.close();

    var count: usize = 0;

    var arr_instructions = try allocator.alloc([]const u8, 6);

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read file: {s}", .{@errorName(err)});
        return null;
    }) |line| {
        arr_instructions[count] = line;
        count += 1;
    }

    return arr_instructions;
}
