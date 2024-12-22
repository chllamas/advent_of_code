const std = @import("std");
const file_input = "input.txt";

fn part1(_: std.mem.Allocator, buffer: []const u8) !void {
    var sum: u128 = 0;
    var buyers = std.mem.splitScalar(u8, buffer, '\n');
    while (buyers.next()) |buyer| {
        var secret_number = try std.fmt.parseInt(u64, buyer, 10);
        defer sum += secret_number;
        for (0..2000) |_| {
            secret_number = @mod((secret_number * 64) ^ secret_number, 16777216);
            secret_number = @mod((@divFloor(secret_number, 32)) ^ secret_number, 16777216);
            secret_number = @mod((secret_number * 2048) ^ secret_number, 16777216);
        }
    }
    std.debug.print("Result: {}\n", .{sum});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buffer = try readFile(allocator, file_input[0..]);
    const buffer_trimmed = std.mem.trimRight(u8, buffer, "\n");
    defer allocator.free(buffer);

    try part1(allocator, buffer_trimmed);
    // try part2(allocator, buffer);
}

fn readFile(allocator: std.mem.Allocator, file_name: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
