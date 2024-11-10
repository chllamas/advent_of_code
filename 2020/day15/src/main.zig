const std = @import("std");

const num_turns = 10;

const test_input = [_]u32{ 0, 3, 6 };
const real_input = [_]u32{ 0, 8, 15, 2, 12, 1, 4 };

pub fn main() !void {
    const input: []const u32 = test_input[0..];
    const allocator = std.heap.page_allocator;

    var spoken_numbers = std.AutoHashMap(u32, u32).init(allocator);
    defer spoken_numbers.deinit();

    var last_spoken: u32 = 0;
    for (0.., input) |i, x| {
        const turn: u32 = @intCast(i);
        try spoken_numbers.putNoClobber(x, turn + 1);
        last_spoken = x;
    }

    for (input.len + 1..num_turns + 1) |i| {
        const turn: u32 = @intCast(i);
        const last_time_yelled = spoken_numbers.get(last_spoken);
        if (last_time_yelled == null) {
            std.debug.print("Turn {}: {} is new, yelling 0\n", .{ turn, last_spoken });
            last_spoken = 0;
            try spoken_numbers.put(0, turn);
        } else {
            std.debug.print("Turn {}: {} was yelled at {}, yelling {}\n", .{ turn, last_spoken, last_time_yelled.?, turn - last_time_yelled.? });
            last_spoken = turn - last_time_yelled.?;
            try spoken_numbers.put(last_spoken, turn);
        }
    }

    std.debug.print("Game end: {}\n", .{last_spoken});
}
