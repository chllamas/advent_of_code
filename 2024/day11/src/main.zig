const std = @import("std");

const StartStone = u32;
const test_stones: [5]StartStone = .{ 0, 1, 10, 99, 999 };
const input_stones: [8]StartStone = .{ 2, 54, 992917, 5270417, 2514, 28561, 0, 990 };
const input: []const StartStone = test_stones[0..];

fn part1() !void {}

pub fn main() !void {
    try part1();
}
