const std = @import("std");

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    var calibration: u64 = 0;
    var stack = std.ArrayList(u64).init(allocator);
    defer stack.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var iter = std.mem.splitSequence(u8, line, ": ");
        const test_number = try std.fmt.parseInt(u64, iter.next().?, 10);
        var operators_iter = std.mem.splitScalar(u8, iter.next().?, ' ');
        try stack.append(try std.fmt.parseInt(u64, operators_iter.next().?, 10));

        while (operators_iter.next()) |_operator| {
            if (stack.items.len == 0) break;
            if (_operator.len == 0) continue;

            const operator = try std.fmt.parseInt(u64, _operator, 10);
            var t = std.ArrayList(u64).init(allocator);
            defer t.deinit();
            while (stack.popOrNull()) |elem| {
                const a: u64 = elem + operator;
                const b: u64 = elem * operator;

                if (a <= test_number)
                    try t.append(a);

                if (b <= test_number)
                    try t.append(b);
            }

            try stack.appendSlice(t.items);
        }

        for (stack.items) |x| {
            if (x == test_number) {
                calibration += test_number;
                break;
            }
        }
    }

    std.debug.print("Result: {}\n", .{calibration});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, buffer);
}
