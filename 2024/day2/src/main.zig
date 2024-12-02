const std = @import("std");

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

    report_loop: while (reports_iter.next()) |report| {
        if (report.len == 0) continue;

        var unsafe_situation = false; // if true, then on next unsafe we continue
        var is_increasing = true;
        var is_decreasing = true;

        var level_iter = std.mem.splitScalar(u8, report, ' ');
        var prev = try std.fmt.parseInt(i32, level_iter.next().?, 10);
        while (level_iter.next()) |level| {
            if (level.len == 0) continue;

            const next: i32 = try std.fmt.parseInt(i32, level, 10);
            const diff: i32 = next - prev;
            defer prev = next;

            if (!(@abs(diff) >= 1 and @abs(diff) <= 3)) {
                if (unsafe_situation)
                    continue :report_loop
                else {
                    unsafe_situation = true;
                    continue;
                }
            }

            is_increasing = is_increasing and diff > 0;
            is_decreasing = is_decreasing and diff < 0;

            if (!is_decreasing and !is_increasing)
                continue :report_loop;
        }

        safe_reports += 1;
    }

    std.debug.print("Safe reports: {}\n", .{safe_reports});
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
