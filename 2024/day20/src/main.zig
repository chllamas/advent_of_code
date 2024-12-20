const std = @import("std");

const Track = struct {
    x: usize,
    y: usize,
    t: u32,
};

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

fn findStartPiece(racetrack: []const []const u8) Track {
    for (0.., racetrack) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'S') return .{ .x = x, .y = y, .t = 0 };
        }
    }
    unreachable;
}

fn outlineTrack(allocator: std.mem.Allocator, racetrack: []const []const u8) ![]Track {
    var last = findStartPiece(racetrack);
    var current = .{ .x = last.x, .y = last.y - 1, .t = 1 }; // do we hard code this to help it?
    while (true) {
        // NOTE: We will break as soon as we see 'E' to be next

        // chekc each direction until we find a track piece that is not the last one and that is not E
    }
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
