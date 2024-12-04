const std = @import("std");
const get_inst = @import("get_instructions.zig");
const parser = @import("parser.zig");

pub fn execute(alloc: std.mem.Allocator) !void {
    var arena_allocator = std.heap.ArenaAllocator.init(alloc);
    const arena = arena_allocator.allocator();

    defer arena_allocator.deinit();

    var instructions: [][]const u8 = undefined;
    if (try get_inst.get_instructions(arena)) |i| {
        instructions = i;
    } else {
        return error.InstructionsFoundNull;
    }

    // var sum: usize = 0;

    // Was struggling with Part 2, couldn't find the correct ans for a long time; :-(
    // Then it seems I was not parsing and calculating the instructs line by line, so the
    // state got reset for each line; but dummy I had to combine all the lines into one
    // string and then parse it and get the result; Really Bummer.
    const long_inst: []const u8 = try std.mem.concat(arena, u8, instructions);

    // for (instructions) |inst| {
    //     const res = try execute_instructions(try parse_instruction(arena, inst));
    //     sum += res;
    // }

    std.debug.print("\nPart - I\n", .{});
    var sum: usize = try execute_instructions(try parser.parse_instruction(arena, long_inst, false));
    std.debug.print("Result {d}\n", .{sum});

    std.debug.print("\nPart - II\n", .{});
    sum = try execute_instructions(try parser.parse_instruction(arena, long_inst, true));
    std.debug.print("Result {d}\n", .{sum});
}

fn execute_instructions(inst: std.ArrayList([]const u8)) !usize {
    var result: usize = 0;

    for (inst.items) |i| {
        var split = std.mem.splitSequence(u8, i, ",");

        const l_value = try std.fmt.parseInt(usize, std.mem.trimLeft(u8, split.next().?, "mul("), 10);
        const r_value = try std.fmt.parseInt(usize, std.mem.trimRight(u8, split.next().?, ")"), 10);

        result += (l_value * r_value);
    }

    return result;
}
