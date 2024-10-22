const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,
};

const test_steps: u8 = 16;
const input_steps: u8 = 64;
const this_steps = test_steps;

fn startingCoord(map: []const []const u8) Coord {
    for (0.., map) |y, row| {
        for (0.., row) |x, ch| {
            if (ch == 'S')
                return .{ .x = x, .y = y };
        }
    }
    @panic("Couldn't locate S");
}

fn createMap(allocator: std.mem.Allocator, buffer: []const u8) ![]const []const u8 {
    var map = std.ArrayList([]const u8).init(allocator);
    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        try map.append(line);
    }
    return try map.toOwnedSlice();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const map = try createMap(allocator, buffer);
    defer allocator.free(map);

    var visit_queue = std.ArrayList(Coord).init(allocator);
    defer visit_queue.deinit();

    try visit_queue.append(startingCoord(map));

    var steps: u8 = 0;
    while (steps < this_steps) : (steps += 1) {
        const n = visit_queue.items.len;
        for (0..n) |_| {
            // we only pop the steps we can do *this* run
            const coord = visit_queue.pop();
            // BFS here safely
        }
    }

    std.debug.print("After {d} steps, we can reach {d} plots\n", .{ this_steps, visit_queue.items.len });
}
