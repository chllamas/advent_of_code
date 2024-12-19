const std = @import("std");

const file_input = "test.txt";

fn isPossible(trials: *std.ArrayList(usize), patterns: []const []const u8, expr: []const u8) !bool {
    if (trials.items.len == 0) return false;
    for (trials.items) |trial| {}
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(file_input[0..], .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}
