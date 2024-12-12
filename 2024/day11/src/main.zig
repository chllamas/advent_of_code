const std = @import("std");

const Stone = u64;
const test_stones: [2]Stone = .{ 125, 17 };
const input_stones: [8]Stone = .{ 2, 54, 992917, 5270417, 2514, 28561, 0, 990 };
const input: []const Stone = input_stones[0..];

const _Blink = enum { single, split };
const Blink = union(_Blink) {
    single: Stone,
    split: [2]Stone,
};

// Optimized thanks to [this](https://www.reddit.com/r/adventofcode/comments/1hbm0al/comment/m1lxra1/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)
// rust code's `count_digits` function translated for zig
fn numDigits(comptime T: type, _value: T) usize {
    const value: f64 = @floatFromInt(_value);
    const parsed: usize = @intFromFloat(std.math.log10(value));
    return parsed + 1;
}

fn isEvenDigits(comptime T: type, value: T) bool {
    return @mod(numDigits(T, value), 2) == 0;
}

fn splitStone(stone: Stone) [2]Stone {
    // PERF: Defintely need to optimize splitting the stone into two
    const n: usize = @divExact(numDigits(Stone, stone), 2);
    var value = stone;
    var split1: Stone = 0;

    for (0..n) |x| {
        const t: Stone = @mod(value, 10);
        value = @divFloor(value, 10);
        split1 += t * (std.math.pow(Stone, 10, @intCast(x)));
    }

    return [2]Stone{ value, split1 };
}

fn blink(store: *std.AutoHashMap(Stone, Blink), stone: Stone) !Blink {
    if (store.get(stone)) |result|
        return result;

    const result: Blink = if (stone == 0)
        .{ .single = 1 }
    else if (isEvenDigits(Stone, stone))
        .{ .split = splitStone(stone) }
    else
        .{ .single = stone * 2024 };

    try store.*.putNoClobber(stone, result);
    return result;
}

fn part1() !void {
    const allocator = std.heap.page_allocator;

    var stones_memory = std.AutoHashMap(Stone, Blink).init(allocator);
    defer stones_memory.deinit();

    var stones_buffer = std.ArrayList(Stone).init(allocator);
    defer stones_buffer.deinit();

    var stones = try allocator.alloc(Stone, input.len);
    defer allocator.free(stones);
    std.mem.copyForwards(Stone, stones, input);

    for (0..75) |_| {
        for (stones) |stone| switch (try blink(&stones_memory, stone)) {
            .single => |new_stone| try stones_buffer.append(new_stone),
            .split => |stone_set| try stones_buffer.appendSlice(stone_set[0..]),
        };

        const t = stones;
        stones = try stones_buffer.toOwnedSlice();
        allocator.free(t);
    }

    std.debug.print("Result: {} stones\n", .{stones.len});
}

pub fn main() !void {
    try part1();
}
