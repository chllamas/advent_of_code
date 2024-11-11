const std = @import("std");

// a -> b | c -> d (inclusive)
const Range = struct {
    a: u64,
    b: u64,
    c: u64,
    d: u64,
};

fn parseRanges(ranges: *std.StringHashMap(Range), buffer: []const u8) !usize {
    var count: usize = 0;
    var lines = std.mem.splitScalar(u8, buffer, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) break;
        var iter = std.mem.splitSequence(u8, line, ": ");
        const name = iter.next().?;
        var rangesIter = std.mem.splitSequence(u8, iter.next().?, " or ");
        var r1 = std.mem.splitScalar(u8, rangesIter.next().?, '-');
        var r2 = std.mem.splitScalar(u8, rangesIter.next().?, '-');
        count += 1;
        try ranges.*.putNoClobber(name, .{
            .a = try std.fmt.parseInt(u64, r1.next().?, 10),
            .b = try std.fmt.parseInt(u64, r1.next().?, 10),
            .c = try std.fmt.parseInt(u64, r2.next().?, 10),
            .d = try std.fmt.parseInt(u64, r2.next().?, 10),
        });
    }

    return count;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var blocks = std.mem.splitSequence(u8, buffer, "\n\n");

    var ranges = std.StringHashMap(Range).init(allocator);
    const num_ranges = try parseRanges(&ranges, blocks.next().?);
    defer ranges.deinit();

    var range_configuration = try allocator.alloc(std.ArrayList([]const u8), num_ranges);
    for (range_configuration) |*config| {
        var ranges_iter = ranges.keyIterator();
        config.* = std.ArrayList(*[]const u8).init(allocator);
        while (ranges_iter.next()) |range| {
            try config.*.append(range);
        }
    }

    var valid_tickets = std.ArrayList([]const u8).init(allocator);
    try valid_tickets.append(blocks.next().?[13..]); // start by appending my ticket which is valid by default
    defer valid_tickets.deinit();

    var nearby_tickets_iter = std.mem.splitScalar(u8, blocks.next().?[16..], '\n');
    tickets_loop: while (nearby_tickets_iter.next()) |ticket| {
        if (ticket.len == 0) continue;

        var fields_iter = std.mem.splitScalar(u8, ticket, ',');
        while (fields_iter.next()) |x_str| {
            const x = try std.fmt.parseInt(u64, x_str, 10);

            for (ranges.items) |*range| {
                if (!((x >= range.*.a and x <= range.*.b) or (x >= range.*.c and x <= range.*.d))) {
                    continue :tickets_loop;
                }
            }

            // TODO: Modify valid spots for the fields

            try valid_tickets.append(ticket);
        }
    }

    // TODO: Free the range configurations
}
