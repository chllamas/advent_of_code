const std = @import("std");
const splitChar = std.mem.splitScalar;
const map_size_x: usize = 20;
const map_size_y: usize = 20;

const Coord = struct {
    x: i32,
    y: i32,
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

    var perimeter: u32 = 0;
    var marker = Coord{ .x = 0, .y = 0 };
    var lines = splitChar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len > 0) {
            var instructions = splitChar(u8, line, ' ');
            const direction = instructions.next().?[0];
            const length = try std.fmt.parseInt(u8, instructions.next().?, 10);
            // const idk = instructions.next().?;
            marker = switch (direction) {
                'U' => .{ .x = marker.x, .y = marker.y - length },
                'D' => .{ .x = marker.x, .y = marker.y + length },
                'R' => .{ .x = marker.x + length, .y = marker.y },
                'L' => .{ .x = marker.x - length, .y = marker.y },
                else => @panic("Unhandled char"),
            };
            perimeter += length;
            try vertices.append(marker);
        }
    }

    try vertices.append(vertices.items[0]);

    var area: i32 = 0;
    for (0..vertices.items.len - 1) |i| {
        const a = vertices.items[i];
        const b = vertices.items[i + 1];
        area += a.x * b.y;
        area -= a.y * b.x;
    }

    // This was possible from this post here: https://www.reddit.com/r/adventofcode/comments/18l0qtr/comment/kdveugr/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    // I still don't understand why we need to halven the perimeter first then add 1, but I was simply adding area + perimeter
    const calc: u32 = @divTrunc(@abs(area), 2) + @divTrunc(perimeter, 2) + 1;

    std.debug.print("Total: {d}\n", .{calc});
}
