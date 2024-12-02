const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var safe_reports: u32 = 0;
    var reports_iter = std.mem.splitScalar(u8, buffer, '\n');
    while (reports_iter.next()) |report| {
        if (report.len == 0) continue;

        var level_iter = std.mem.splitScalar(u8, report, ' ');
        while (level_iter.next()) |level| {
            if (level.len == 0) continue;
            safe_reports += 1;
        }
    }

    std.debug.print("Safe reports: {}\n", .{safe_reports});
}
