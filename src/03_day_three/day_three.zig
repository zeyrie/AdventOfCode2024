const std = @import("std");
const get_inst = @import("get_instructions.zig");

pub fn execute_day_three(alloc: *std.mem.Allocator) !void {
    var arena_allocator = std.heap.ArenaAllocator.init(alloc.*);
    const arena = arena_allocator.allocator();

    defer arena_allocator.deinit();

    var instructions: [][]const u8 = undefined;
    if (try get_inst.get_instructions(arena)) |i| {
        instructions = i;
    } else {
        return error.InstructionsFoundNull;
    }
    std.log.info("Instructions Received", .{});

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

    const sum: usize = try execute_instructions(try parse_instruction(arena, long_inst));

    std.log.info("Final Result {d}", .{sum});
}

fn execute_instructions(inst: std.ArrayList([]const u8)) !usize {
    var result: usize = 0;

    for (inst.items) |i| {
        var split = std.mem.splitSequence(u8, i, ",");

        const l_value = try std.fmt.parseInt(usize, std.mem.trimLeft(u8, split.next().?, "mul("), 10);
        const r_value = try std.fmt.parseInt(usize, std.mem.trimRight(u8, split.next().?, ")"), 10);

        const mul = l_value * r_value;

        if (mul == 112_077) {
            std.debug.print("\nItem Found: {s}\n", .{i});
        }

        result += (l_value * r_value);
    }

    return result;
}

const State = enum {
    m,
    u,
    l,
    d,
    o,
    n,
    single_quote,
    t,
    l_param,
    l_digit_1,
    l_digit_2,
    l_digit_3,
    comma,
    r_digit_1,
    r_digit_2,
    r_digit_3,
    r_param,
    Invalid,
};

fn parse_instruction(alloc: std.mem.Allocator, inst: []const u8) !std.ArrayList([]const u8) {
    const len = inst.len;

    var start_index: usize = undefined;
    var end_index: usize = undefined;
    var state: State = .Invalid;

    var valid_instructions = std.ArrayList([]const u8).init(alloc);

    var i: usize = 0;

    // Wrong implementation of a parser/state machine; resulted in keeping separate variables
    // for keeping track of do and don't :-/
    var is_do: ?bool = null;
    var execute: bool = true;

    while (i < len) {
        const ch = inst[i];
        switch (ch) {
            'd' => {
                state = .d;
            },
            'o' => {
                if (state == .d) {
                    state = .o;
                } else {
                    state = .Invalid;
                }
            },
            'n' => {
                if (state == .o) {
                    state = .n;
                } else {
                    state = .Invalid;
                }
            },
            '\'' => {
                if (state == .n) {
                    state = .single_quote;
                } else {
                    state = .Invalid;
                }
            },
            't' => {
                if (state == .single_quote) {
                    state = .t;
                } else {
                    state = .Invalid;
                }
            },
            'm' => {
                if (execute) {
                    state = .m;
                    start_index = i;
                } else {
                    state = .Invalid;
                }
            },
            'u' => {
                if (state == .m) {
                    state = .u;
                } else {
                    state = .Invalid;
                }
            },
            'l' => {
                if (state == .u) {
                    state = .l;
                } else {
                    state = .Invalid;
                }
            },
            '(' => {
                switch (state) {
                    .l => {
                        state = .l_param;
                    },
                    .o => {
                        is_do = true;
                        state = .l_param;
                    },
                    .t => {
                        is_do = false;
                        state = .l_param;
                    },
                    else => {
                        state = .Invalid;
                    },
                }
            },
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                switch (state) {
                    .l_param => {
                        state = .l_digit_1;
                    },
                    .l_digit_1 => {
                        state = .l_digit_2;
                    },
                    .l_digit_2 => {
                        state = .l_digit_3;
                    },
                    .comma => {
                        state = .r_digit_1;
                    },
                    .r_digit_1 => {
                        state = .r_digit_2;
                    },
                    .r_digit_2 => {
                        state = .r_digit_3;
                    },
                    else => {
                        state = .Invalid;
                    },
                }
            },
            ',' => {
                if (state == .l_digit_1 or state == .l_digit_2 or state == .l_digit_3) {
                    state = .comma;
                } else {
                    state = .Invalid;
                }
            },
            ')' => {
                switch (state) {
                    .r_digit_1, .r_digit_2, .r_digit_3 => {
                        if (execute) {
                            state = .r_param;
                            end_index = i;
                            try valid_instructions.append(inst[start_index .. end_index + 1]);
                        } else {
                            state = .Invalid;
                        }
                    },
                    .l_param => {
                        if (is_do) |s| {
                            if (s) {
                                execute = true;
                            } else {
                                execute = false;
                            }
                            state = .r_param;
                        } else {
                            state = .Invalid;
                        }
                    },
                    else => {
                        state = .Invalid;
                    },
                }
            },
            else => {
                state = .Invalid;
            },
        }
        i += 1;
    }

    return valid_instructions;
}

test "parse handle" {
    // var txt = ",what(936,615)*:don't()who()[[[~:mul(36,505)~do();&{-*mul(431,2))  select(){}#*do()+]mul(617,948)$don't()mul(117,664){) &why()<,why()mul(271,823)whdo()at(674,989);";
    var txt = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    const alloc = std.testing.allocator;

    var expected_value = std.ArrayList([]const u8).init(alloc);
    defer expected_value.deinit();

    // try expected_value.append("mul(36,505)");
    // try expected_value.append("mul(431,2)");
    // try expected_value.append("mul(617,948)");
    // try expected_value.append("mul(117,664)");
    // try expected_value.append("mul(271,823)");

    // try expected_value.append("mul(431,2)");
    // try expected_value.append("mul(617,948)");

    try expected_value.append("mul(2,4)");
    try expected_value.append("mul(8,5)");

    const value = try parse_instruction(alloc, txt[0..]);
    defer value.deinit();

    std.debug.print("\n\n", .{});

    try std.testing.expectEqualDeep(expected_value, value);
}
