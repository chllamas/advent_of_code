const std = @import("std");

const num_turns = 30000000;

const test_input = [_]u32{ 0, 3, 6 };
const real_input = [_]u32{ 0, 8, 15, 2, 12, 1, 4 };

pub fn main() !void {
    const input: []const u32 = real_input[0..];
    const allocator = std.heap.page_allocator;

    var spoken_numbers = std.AutoHashMap(u32, u32).init(allocator);
    defer spoken_numbers.deinit();

    var last_spoken: u32 = 0;
    for (0.., input) |i, x| {
        const turn: u32 = @intCast(i);
        last_spoken = x;
        if (i < input.len - 1)
            try spoken_numbers.putNoClobber(x, turn + 1);
    }

    for (input.len + 1..num_turns + 1) |i| {
        const turn: u32 = @intCast(i);
        const t = last_spoken;
        const last_time_yelled = spoken_numbers.get(t);
        if (last_time_yelled == null) {
            last_spoken = 0;
        } else {
            last_spoken = turn - last_time_yelled.? - 1;
        }
        try spoken_numbers.put(t, turn - 1);
    }

    std.debug.print("Game end: {}\n", .{last_spoken});
}
