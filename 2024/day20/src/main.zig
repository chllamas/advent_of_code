const std = @import("std");

const file_input = "test.txt";

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buffer = try readFile(allocator, file_input[0..]);
    defer allocator.free(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}

fn readFile(allocator: std.mem.Allocator, file_name: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}

fn createGraph(allocator: std.mem.Allocator, buffer: []const u8) ![]const []const u8 {
    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }
    return try list.toOwnedSlice();
}
