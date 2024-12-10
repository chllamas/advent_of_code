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

// We can guarantee the values won't be null just go ahead and unwrap the values of returned slice
fn process(arr: []?u32) []?u32 {
    var swp_idx: usize = 0;
    for (0..arr.len) |dt| {
        const i: usize = arr.len - 1 - dt;
        if (arr[i] == null) continue;
        while (arr[swp_idx] != null and swp_idx < i) : (swp_idx += 1) {}
        if (swp_idx == i) break;
        arr[swp_idx] = arr[i].?;
    }
    return arr[0 .. swp_idx + 1];
}
//
// We can guarantee the values won't be null just go ahead and unwrap the values of returned slice
fn processFiles(arr: []?u32) []?u32 {
    var i: usize = arr.len - 1;
    while (i > 0) : (i -= 1) {
        if (arr[i] == null) continue;
        var t: usize = i - 1;
        while (arr[t] == arr[i]) : (t -= 1) {}
        defer i = t;
        const slice = arr[t + 1 .. i + 1];
        // TODO: Now try to move the slice back to a null slot of this size
    }
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const preprocessed_arr = try createPreprocessedFormat(allocator, buffer);
    const arr = process(preprocessed_arr);
    var sum: u64 = 0;
    for (0.., arr) |i, ch| {
        const val: u32 = @intCast(i);
        sum += val * ch.?;
    }
    std.debug.print("{}\n", .{sum});
}

fn part2(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const arr = try createPreprocessedFormat(allocator, buffer);
    processFiles(arr);
    var sum: u64 = 0;
    for (0.., arr) |i, ch| {
        if (ch) |t| {
            const val: u32 = @intCast(i);
            sum += val * t;
        }
    }
    std.debug.print("{}\n", .{sum});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // try part1(allocator, std.mem.trimRight(u8, buffer, "\n"));
    try part2(allocator, std.mem.trimRight(u8, buffer, "\n"));
}
