const std = @import("std");
const get_matrix = @import("get_matrix.zig");

pub fn execute(allocator: std.mem.Allocator) !void {
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    const arena = arena_allocator.allocator();

    defer arena_allocator.deinit();

    var matrix: [][]const u8 = undefined;

    if (try get_matrix.get_matrix(arena)) |mat| {
        matrix = mat;
    } else {
        return error.MatrixNotFound;
    }

    var xmas_count: usize = 0;

    for (matrix, 0..) |row, x| {
        for (row, 0..) |char, y| {
            if (char == 'X') {
                const pos = Position{ .x = @intCast(x), .y = @intCast(y) };

                xmas_count += try find_xmas_horizontally(arena, pos, matrix);
                xmas_count += try find_xmas_vertically(arena, pos, matrix);
                xmas_count += try find_xmas_diagionally(arena, pos, matrix);
            }
        }
    }

    std.debug.print("\nPart - I\nXMAS Count: {d}\n", .{xmas_count});

    var x_mas_count: usize = 0;

    for (matrix, 0..) |row, x| {
        for (row, 0..) |char, y| {
            if (char == 'A') {
                const pos = Position{ .x = @intCast(x), .y = @intCast(y) };
                x_mas_count += try find_x_mas(pos, matrix);
            }
        }
    }

    std.debug.print("\nPart - II\nX-MAS Count: {d}\n", .{x_mas_count});
}

const Position = struct { x: i16, y: i16 };

fn find_xmas_horizontally(alloc: std.mem.Allocator, pos: Position, mat: [][]const u8) !u8 {
    var count: u8 = 0;

    const x: usize = @intCast(pos.x);

    var line = try alloc.alloc(u8, 4);

    if (pos.y + 3 < 140) {
        for (0..4) |i| {
            const y: usize = @intCast(pos.y);
            line[i] = mat[x][y + i];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            const file = try std.fs.cwd().createFile("resource/mat.test", .{ .truncate = false });
            defer file.close();

            try file.seekFromEnd(0);
            var buf: [50]u8 = undefined;

            const res = try std.fmt.bufPrint(&buf, "x: {d}, y: {d}\n", .{ pos.x, pos.y });

            _ = try file.writer().write(res);

            count += 1;
        }
    }

    if (pos.y - 3 >= 0) {
        for (0..4) |i| {
            const y: usize = @intCast(pos.y);
            line[i] = mat[x][y - i];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            const file = try std.fs.cwd().createFile("resource/mat.test", .{ .truncate = false });
            defer file.close();

            try file.seekFromEnd(0);
            var buf: [50]u8 = undefined;

            const res = try std.fmt.bufPrint(&buf, "x: {d}, y: {d}\n", .{ pos.x, pos.y });

            _ = try file.writer().write(res);

            count += 1;
        }
    }

    return count;
}

fn find_xmas_vertically(alloc: std.mem.Allocator, pos: Position, mat: [][]const u8) !u8 {
    var count: u8 = 0;

    const y: usize = @intCast(pos.y);

    var line = try alloc.alloc(u8, 4);

    if (pos.x + 3 < 140) {
        for (0..4) |i| {
            const x: usize = @intCast(pos.x);
            line[i] = mat[x + i][y];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            count += 1;
        }
    }

    if (pos.x - 3 >= 0) {
        for (0..4) |i| {
            const x: usize = @intCast(pos.x);
            line[i] = mat[x - i][y];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            count += 1;
        }
    }

    return count;
}

fn find_xmas_diagionally(alloc: std.mem.Allocator, pos: Position, mat: [][]const u8) !u8 {
    var count: u8 = 0;

    var line = try alloc.alloc(u8, 4);

    // for top left
    if ((pos.x - 3 >= 0) and (pos.y - 3 >= 0)) {
        for (0..4) |i| {
            const x: usize = @intCast(pos.x);
            const y: usize = @intCast(pos.y);
            line[i] = mat[x - i][y - i];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            count += 1;
        }
    }

    // for top right
    if ((pos.x - 3 >= 0) and (pos.y + 3 < 140)) {
        for (0..4) |i| {
            const x: usize = @intCast(pos.x);
            const y: usize = @intCast(pos.y);
            line[i] = mat[x - i][y + i];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            count += 1;
        }
    }

    // for bottom left
    if ((pos.x + 3 < 140) and (pos.y - 3 >= 0)) {
        for (0..4) |i| {
            const x: usize = @intCast(pos.x);
            const y: usize = @intCast(pos.y);
            line[i] = mat[x + i][y - i];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            count += 1;
        }
    }

    // for bottom right
    if ((pos.x + 3 < 140) and (pos.y + 3 < 140)) {
        for (0..4) |i| {
            const x: usize = @intCast(pos.x);
            const y: usize = @intCast(pos.y);
            line[i] = mat[x + i][y + i];
        }

        if (std.mem.eql(u8, line, "XMAS")) {
            count += 1;
        }
    }

    return count;
}

fn find_x_mas(pos: Position, mat: [][]const u8) !u8 {
    var count: u8 = 0;

    if ((pos.x + 1 < 140) and (pos.x - 1 >= 0) and (pos.y + 1 < 140) and (pos.y - 1 >= 0)) {
        const x_aPos: usize = @intCast(pos.x);
        const y_aPos: usize = @intCast(pos.y);

        const tl_x_Pos: usize = x_aPos - 1;
        const tl_y_Pos: usize = y_aPos - 1;

        const br_x_Pos: usize = x_aPos + 1;
        const br_y_Pos: usize = y_aPos + 1;

        const tr_x_Pos: usize = tl_x_Pos;
        const tr_y_Pos: usize = tl_y_Pos + 2;

        const bl_x_Pos: usize = br_x_Pos;
        const bl_y_Pos: usize = br_y_Pos - 2;

        if (mat[tl_x_Pos][tl_y_Pos] == 'M' and mat[br_x_Pos][br_y_Pos] == 'S' and mat[tr_x_Pos][tr_y_Pos] == 'M' and mat[bl_x_Pos][bl_y_Pos] == 'S') {
            count += 1;
        }

        if (mat[tl_x_Pos][tl_y_Pos] == 'M' and mat[br_x_Pos][br_y_Pos] == 'S' and mat[tr_x_Pos][tr_y_Pos] == 'S' and mat[bl_x_Pos][bl_y_Pos] == 'M') {
            count += 1;
        }

        if (mat[tl_x_Pos][tl_y_Pos] == 'S' and mat[br_x_Pos][br_y_Pos] == 'M' and mat[tr_x_Pos][tr_y_Pos] == 'S' and mat[bl_x_Pos][bl_y_Pos] == 'M') {
            count += 1;
        }

        if (mat[tl_x_Pos][tl_y_Pos] == 'S' and mat[br_x_Pos][br_y_Pos] == 'M' and mat[tr_x_Pos][tr_y_Pos] == 'M' and mat[bl_x_Pos][bl_y_Pos] == 'S') {
            count += 1;
        }
    }

    return count;
}
