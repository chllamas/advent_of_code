const std = @import("std");

fn reportLength(report: []const u8) usize {
    var count: usize = 0;
    var iter = std.mem.splitScalar(u8, report, ' ');
    while (iter.next()) |t| {
        if (t.len == 0) continue;
        count += 1;
    }
    return count;
}

fn reportIsSafe(report: []const u8, ignore_element: ?usize) !bool {
    var is_increasing = true;
    var is_decreasing = true;

    var i: usize = 0;
    var iter = std.mem.splitScalar(u8, report, ' ');
    var prev: i32 = try std.fmt.parseInt(i32, iter.next().?, 10);

    if (ignore_element) |idx| {
        if (idx == 0) {
            prev = try std.fmt.parseInt(i32, iter.next().?, 10);
            i += 1;
        }
    }

    while (iter.next()) |level| {
        if (level.len == 0) continue;

        defer i += 1;
        if (ignore_element) |idx| {
            if (idx == i + 1)
                continue;
        }

        const next: i32 = try std.fmt.parseInt(i32, level, 10);
        const diff: i32 = next - prev;
        defer prev = next;

        if (!(@abs(diff) >= 1 and @abs(diff) <= 3))
            return false;

        is_increasing = is_increasing and diff > 0;
        is_decreasing = is_decreasing and diff < 0;

        if (!is_decreasing and !is_increasing)
            return false;
    }

    return true;
}

fn part1(buffer: []const u8) !void {
    var safe_reports: u32 = 0;
    var reports_iter = std.mem.splitScalar(u8, buffer, '\n');
    report_loop: while (reports_iter.next()) |report| {
        if (report.len == 0) continue;

        var is_increasing = true;
        var is_decreasing = true;

        var level_iter = std.mem.splitScalar(u8, report, ' ');
        var prev = try std.fmt.parseInt(i32, level_iter.next().?, 10);
        while (level_iter.next()) |level| {
            if (level.len == 0) continue;

            const next: i32 = try std.fmt.parseInt(i32, level, 10);
            const diff: i32 = next - prev;

            if (!(@abs(diff) >= 1 and @abs(diff) <= 3))
                continue :report_loop;

            is_increasing = is_increasing and diff > 0;
            is_decreasing = is_decreasing and diff < 0;

            if (!is_decreasing and !is_increasing)
                continue :report_loop;

            prev = next;
        }

        safe_reports += 1;
    }

    std.debug.print("Safe reports: {}\n", .{safe_reports});
}

fn part2(buffer: []const u8) !void {
    var safe_reports: u32 = 0;
    var reports_iter = std.mem.splitScalar(u8, buffer, '\n');

    while (reports_iter.next()) |report| {
        if (report.len == 0) continue;

        if (try reportIsSafe(report, null)) {
            std.debug.print("[{s}] is safe without changes\n", .{report});
            safe_reports += 1;
        } else {
            for (0..reportLength(report)) |i| {
                if (try reportIsSafe(report, i)) {
                    std.debug.print("[{s}] is safe after changing element {d}\n", .{ report, i + 1 });
                    safe_reports += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("Safe reports: {d}\n", .{safe_reports});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // try part1(buffer[0..]);
    try part2(buffer[0..]);
}
