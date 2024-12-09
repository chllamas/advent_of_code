const std = @import("std");

fn createPreprocessedFormat(allocator: std.mem.Allocator, buffer: []const u8) ![]?u32 {
    var i: usize = 0;
    var id: u32 = 0;
    var list = std.ArrayList(?u32).init(allocator);
    while (i < buffer.len - 1) : (i += 2) {
        defer id += 1;
        const file_size: usize = @intCast(buffer[i] - '0');
        const empty_space: usize = @intCast(buffer[i + 1] - '0');
        for (0..file_size) |_| try list.append(id);
        for (0..empty_space) |_| try list.append(null);
    }
    for (0..@intCast(buffer[buffer.len - 1] - '0')) |_| try list.append(id);

    return try list.toOwnedSlice();
}

fn process(arr: []?u32) void {
    var swp_idx: usize = 0;
    for (0..arr.len) |dt| {
        const i: usize = arr.len - 1 - dt;
        if (arr[i] == null) continue;
        while (arr[swp_idx] != null and swp_idx < i) : (swp_idx += 1) {}
        if (swp_idx == i) break;
        arr[swp_idx] = arr[i].?;
    }
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const preprocessed_arr = try createPreprocessedFormat(allocator, buffer);
    process(preprocessed_arr);
    var sum: u32 = 0;
    for (0.., preprocessed_arr) |i, ch| {
        if (ch) |t| {
            const val: u32 = @intCast(i);
            std.debug.print("{} * {}\n", .{ val, t });
            sum += val * t;
        }
    }
    std.debug.print("{}\n", .{sum});
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
}
