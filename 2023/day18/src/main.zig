const std = @import("std");
const splitChar = std.mem.splitScalar;
const map_size_x: usize = 20;
const map_size_y: usize = 20;

const Coord = struct {
    x: i64,
    y: i64,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var vertices = std.ArrayList(Coord).init(allocator);
    defer vertices.deinit();

    var perimeter: u64 = 0;
    var marker = Coord{ .x = 0, .y = 0 };
    var lines = splitChar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len > 0) {
            var instructions = splitChar(u8, line, ' ');
            _ = instructions.next().?;
            _ = instructions.next().?;
            const hex_str = instructions.next().?;
            const direction = hex_str[hex_str.len - 2];
            const length = try std.fmt.parseInt(i32, hex_str[2 .. hex_str.len - 2], 16);
            std.debug.print("string {s} has length of: {d}\n", .{ hex_str, length });
            marker = switch (direction) {
                '3' => .{ .x = marker.x, .y = marker.y - length },
                '1' => .{ .x = marker.x, .y = marker.y + length },
                '0' => .{ .x = marker.x + length, .y = marker.y },
                '2' => .{ .x = marker.x - length, .y = marker.y },
                else => @panic("Unhandled char"),
            };
            perimeter += @intCast(length);
            try vertices.append(marker);
        }
    }

    try vertices.append(vertices.items[0]);

    var area: i64 = 0;
    for (0..vertices.items.len - 1) |i| {
        const a = vertices.items[i];
        const b = vertices.items[i + 1];
        std.debug.print("Running area: {d}\n", .{area});
        area += a.x * b.y;
        area -= a.y * b.x;
    }

    // This was possible from this post here: https://www.reddit.com/r/adventofcode/comments/18l0qtr/comment/kdveugr/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    // I still don't understand why we need to halven the perimeter first then add 1, but I was simply adding area + perimeter
    area = @intCast(@divTrunc(@abs(area), 2));
    const a: u64 = @intCast(area);
    const calc: u64 = a + @divTrunc(perimeter, 2) + 1;

    std.debug.print("Total: {d}\n", .{calc});
}
