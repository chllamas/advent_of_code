const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,
};

const test_steps: u8 = 6;
const input_steps: u8 = 64;
const this_steps = input_steps;

fn hasCoord(lst: []const Coord, x: usize, y: usize) bool {
    for (lst) |*coord| {
        if (coord.*.x == x and coord.*.y == y)
            return true;
    }
    return false;
}

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

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const map = try createMap(allocator, buffer);
    defer allocator.free(map);

    var visit_queue = std.ArrayList(Coord).init(allocator);
    defer visit_queue.deinit();

    var stack = std.ArrayList(Coord).init(allocator);
    defer stack.deinit();

    try visit_queue.append(startingCoord(map));

    for (0..this_steps) |_| {
        try stack.appendSlice(visit_queue.items);
        visit_queue.clearRetainingCapacity();

        while (stack.popOrNull()) |coord| {
            if (coord.x > 0 and map[coord.y][coord.x - 1] != '#' and !hasCoord(visit_queue.items, coord.x - 1, coord.y))
                try visit_queue.append(.{ .x = coord.x - 1, .y = coord.y });

            if (coord.x < map[0].len - 1 and map[coord.y][coord.x + 1] != '#' and !hasCoord(visit_queue.items, coord.x + 1, coord.y))
                try visit_queue.append(.{ .x = coord.x + 1, .y = coord.y });

            if (coord.y < map.len - 1 and map[coord.y + 1][coord.x] != '#' and !hasCoord(visit_queue.items, coord.x, coord.y + 1))
                try visit_queue.append(.{ .x = coord.x, .y = coord.y + 1 });

            if (coord.y > 0 and map[coord.y - 1][coord.x] != '#' and !hasCoord(visit_queue.items, coord.x, coord.y - 1))
                try visit_queue.append(.{ .x = coord.x, .y = coord.y - 1 });
        }
    }

    std.debug.print("After {d} steps, we can reach {d} plots\n", .{ this_steps, visit_queue.items.len });
}
