const std = @import("std");
const splitChar = std.mem.splitScalar;
const map_size_x: usize = 20;
const map_size_y: usize = 20;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // This is a 2d array where true is a trench dug out and false is just dirt
    var map = std.ArrayList(std.ArrayList(bool)).init(allocator);
    defer map.deinit();

    for (0..map_size_y) |y| {
        try map.append(std.ArrayList(bool).init(allocator));
        for (0..map_size_x) |_| {
            const t = map.getLast();
            try map.items[y].append(false);
        }
    }

    var px: usize = 0;
    var py: usize = 0;
    const lines = splitChar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len > 0) {
            const instructions = splitChar(u8, line, ' ');
            const direction = instructions.next().?[0];
            const num_steps = try std.fmt.parseInt(u8, instructions.next().?, 10);
            // const idk = instructions.next().?;
            switch (direction) {
                'U' => {},
                'D' => {},
                'R' => {},
                'L' => {},
                else => @panic("Unhandled char"),
            }
        }
    }
}
