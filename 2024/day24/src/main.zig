const std = @import("std");

const allocator = std.heap.page_allocator;

// why a u46? because out input has max z45 so we use that hard coded oh well
fn part1(file_name: []const u8) !u46 {
    const _buffer = try readFile(file_name);
    const buffer = std.mem.trimRight(u8, _buffer, "\n");
    defer allocator.free(buffer);

    return 0;
}

pub fn main() !void {
    std.debug.assert(try part1("test_small.txt"[0..]) == 4);
    std.debug.assert(try part1("test_large.txt"[0..]) == 2024);
    std.debug.print("Part 1 Result: {}\n", .{try part1("input.txt"[0..])});
}

fn readFile(file_name: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
