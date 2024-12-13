const std = @import("std");

const Coord = struct {
    x: u64,
    y: u64,

    fn add(self: Coord, other: Coord) Coord {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};

fn solve(allocator: std.mem.Allocator, opt_a: Coord, opt_b: Coord, target: Coord) !u32 {
    const gcd_x = std.math.gcd(opt_a.x, opt_b.x);
    const gcd_y = std.math.gcd(opt_a.y, opt_b.y);

    if (gcd_x == 0 or gcd_y == 0 or @mod(target.x, gcd_x) != 0 or @mod(target.y, gcd_y) != 0)
        return 0;

    var stack = std.ArrayList(Coord).init(allocator);
    try stack.append(.{ .x = 0, .y = 0 });
    defer stack.deinit();

    var buffer = std.ArrayList(Coord).init(allocator);
    defer buffer.deinit();

    var steps: u32 = 1;

    while (true) : (steps += 1) {
        while (stack.popOrNull()) |node| {
            if (node.x == target.x and node.y == target.y)
                return steps;

            try buffer.append(node.add(opt_a));
            try buffer.append(node.add(opt_b));
        }

        try stack.appendSlice(buffer.items);
        buffer.clearAndFree();
    }
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var steps: u32 = 0;
    defer std.debug.print("Least steps: {}\n", .{steps});

    var machines = std.mem.splitSequence(u8, buffer, "\n\n");
    while (machines.next()) |machine| {
        var iter = std.mem.splitScalar(u8, machine, '\n');
        var button_a = std.mem.splitSequence(u8, iter.next().?, ", ");
        var button_b = std.mem.splitSequence(u8, iter.next().?, ", ");
        var prize = std.mem.splitSequence(u8, iter.next().?, ", ");
        steps += try solve(
            allocator,
            .{
                .x = try std.fmt.parseInt(u64, button_a.next().?[12..], 10),
                .y = try std.fmt.parseInt(u64, button_a.next().?[2..], 10),
            },
            .{
                .x = try std.fmt.parseInt(u64, button_b.next().?[12..], 10),
                .y = try std.fmt.parseInt(u64, button_b.next().?[2..], 10),
            },
            .{
                .x = try std.fmt.parseInt(u64, prize.next().?[9..], 10),
                .y = try std.fmt.parseInt(u64, prize.next().?[2..], 10),
            },
        );
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    // try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}
