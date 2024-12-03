const std = @import("std");
const get_level = @import("get_level.zig");

pub fn get_num_of_safe_levels(allocator: *std.mem.Allocator) !u16 {
    var levels: []get_level.Level = undefined;

    if (try get_level.get_level(allocator)) |l| {
        levels = l;
    } else {
        return error.FoundNilLevels;
    }

    return try get_safe_count_for(allocator, &levels);
}

fn get_safe_count_for(alloc: *std.mem.Allocator, levels: *[]get_level.Level) !u16 {
    const lvls = levels.*;
    var safe_lvl_count: u16 = 0;

    for (lvls) |level| {
        if (check_if_lvl_safe(level) or try is_valid_on_removal(alloc, level)) {
            safe_lvl_count += 1;
        }
    }

    std.debug.print("Safe Level count: {d}", .{safe_lvl_count});
    return safe_lvl_count;
}

fn is_valid_on_removal(alloc: *std.mem.Allocator, lvl: get_level.Level) !bool {
    const seq = lvl.flr;
    for (0..seq.len) |i| {
        const new_seq = try get_lvl_removing_flr_at(alloc, @intCast(i), lvl);
        if (check_if_lvl_safe(new_seq.*)) {
            return true;
        }
    }
    return false;
}

fn check_if_lvl_safe(level: get_level.Level) bool {
    const len = level.flr.len;
    var i: u16 = 0;
    var j = i + 1;

    const is_asc = level.flr[i] < level.flr[j];

    while (i < len) {
        if (j == len) {
            return true;
        }
        if (!check_if_hierarchy_pass(is_asc, level.flr[i], level.flr[j])) {
            return false;
        }
        if (!isDifferenceSatisfied(level.flr[i], level.flr[j])) {
            return false;
        } else {
            i += 1;
            j = i + 1;
            continue;
        }
    }

    // Will never reach here;
    return false;
}

fn get_lvl_removing_flr_at(alloc: *std.mem.Allocator, index: u16, old_level: get_level.Level) !*get_level.Level {
    std.debug.print("\nRemoved: {d}", .{old_level.flr[index]});
    const new_level = try alloc.create(get_level.Level);
    var new_flr = try alloc.alloc(u16, old_level.flr.len - 1);
    var new_ind: u8 = 0;

    for (old_level.flr, 0..) |flr, ind| {
        if (ind == index) {
            continue;
        }
        new_flr[new_ind] = flr;
        new_ind += 1;
    }

    new_level.* = .{ .flr = new_flr };
    std.debug.print("\nNew: {any}", .{new_level.*});

    return new_level;
}

fn isDifferenceSatisfied(v1: u16, v2: u16) bool {
    const diff = get_abs(v1, v2);
    if (diff == 1) {
        return true;
    } else if (diff == 2) {
        return true;
    } else if (diff == 3) {
        return true;
    } else {
        return false;
    }
}

fn check_if_hierarchy_pass(is_asc: bool, v1: u16, v2: u16) bool {
    if (is_asc) {
        return v1 < v2;
    } else {
        return v2 < v1;
    }
}

fn get_abs(a: u16, b: u16) u16 {
    if (a < b) {
        return b - a;
    } else {
        return a - b;
    }
}

// fn check_if_lvl_safe(alloc: *std.mem.Allocator, level: get_level.Level) !bool {
//     const len = level.flr.len;
//     if (len < 2) {
//         return false;
//     }
//
//     var i: u16 = 0;
//     var j = i + 1;
//
//     const is_asc = level.flr[i] < level.flr[j];
//
//     var is_first_unsafe = true;
//
//     while (i < len) {
//         if (j == len) {
//             return true;
//         }
//         if (!check_if_hierarchy_pass(is_asc, level.flr[i], level.flr[j])) {
//             if (is_first_unsafe) {
//                 std.debug.print("\n\n", .{});
//                 is_first_unsafe = false;
//                 const failed = try check_rest_of_the_flrs(alloc, i, j, level);
//                 std.debug.print("Result: {any}", .{failed});
//                 std.debug.print("\n\n", .{});
//                 return failed;
//             }
//             return false;
//         }
//         if (!isDifferenceSatisfied(level.flr[i], level.flr[j])) {
//             if (is_first_unsafe) {
//                 std.debug.print("\n\n", .{});
//                 is_first_unsafe = false;
//                 const failed = try check_rest_of_the_flrs(alloc, i, j, level);
//                 std.debug.print("Result: {any}", .{failed});
//                 std.debug.print("\n\n", .{});
//                 return failed;
//             }
//             return false;
//         } else {
//             i += 1;
//             j = i + 1;
//             continue;
//         }
//     }
//
//     // Will never reach here;
//     return false;
// }

// fn check_rest_of_the_flrs(alloc: *std.mem.Allocator, i: u16, j: u16, lvl: get_level.Level) !bool {
//     std.debug.print("\nOrg: {any}", .{lvl});
//     var level_cor = try get_lvl_removing_flr_at(alloc, i, lvl);
//     if (check_if_lvl_safe(level_cor.*)) {
//         std.debug.print("\nFirst Success", .{});
//         return true;
//     }
//     level_cor = try get_lvl_removing_flr_at(alloc, j, lvl);
//     if (check_if_lvl_safe(level_cor.*)) {
//         std.debug.print("\nSecond Success", .{});
//         return true;
//     }
//     std.debug.print("\nFailed", .{});
//     return false;
// }
