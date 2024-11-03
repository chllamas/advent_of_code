const std = @import("std");
const compass: [4][2]i32 = .{
    .{ 0, -1 },
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var pos_x: i32 = 0;
    var pos_y: i32 = 0;
    var facing: usize = 1; // 0 north, 1 east, 2 south, 3 west
    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |direction| {
        if (direction.len == 0) break;

        const val = try std.fmt.parseInt(i32, direction[1..], 10);
        switch (direction[0]) {
            'N' => pos_y -= val,
            'S' => pos_y += val,
            'E' => pos_x += val,
            'W' => pos_x -= val,
            'L' => {
                var t: i32 = @intCast(facing);
                t -= @divExact(val, 90);
                t = @mod(t, 4);
                facing = @intCast(t);
            },
            'R' => {
                var t: i32 = @intCast(facing);
                t += @divExact(val, 90);
                t = @mod(t, 4);
                facing = @intCast(t);
            },
            'F' => {
                pos_x += val * compass[facing][0];
                pos_y += val * compass[facing][1];
            },
            else => @panic("Unhandled case"),
        }
    }

    std.debug.print("Distance is {d}\n", .{@abs(pos_x) + @abs(pos_y)});
}
