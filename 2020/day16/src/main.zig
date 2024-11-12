const std = @import("std");

// a -> b | c -> d (inclusive)
const Range = struct {
    a: u64,
    b: u64,
    c: u64,
    d: u64,
};

pub fn main() !void {
    var result: u64 = 1;
    defer std.debug.print("Result is: {}\n", .{result});

    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var blocks = std.mem.splitSequence(u8, buffer, "\n\n");

    var ranges = std.StringHashMap(Range).init(allocator);
    const num_ranges = try parseRanges(&ranges, blocks.next().?);
    defer ranges.deinit();

    // frees at end of main()
    var range_configuration = try allocator.alloc(std.StringHashMap(bool), num_ranges);
    for (range_configuration) |*config| {
        var ranges_iter = ranges.keyIterator();
        config.* = std.StringHashMap(bool).init(allocator);
        while (ranges_iter.next()) |range| {
            try config.putNoClobber(range.*, true);
        }
    }

    const my_ticket = blocks.next().?[13..];
    var valid_tickets = std.ArrayList([]const u8).init(allocator);
    try valid_tickets.append(my_ticket);
    defer valid_tickets.deinit();

    var nearby_tickets_iter = std.mem.splitScalar(u8, blocks.next().?[16..], '\n');
    tickets_loop: while (nearby_tickets_iter.next()) |ticket| {
        if (ticket.len == 0) continue;

        var valid_fields_iter = std.mem.splitScalar(u8, ticket, ',');
        ticket_validator_loop: while (valid_fields_iter.next()) |x_str| {
            const x = try std.fmt.parseInt(u64, x_str, 10);

            var rvals = ranges.valueIterator();
            while (rvals.next()) |range| {
                if ((x >= range.*.a and x <= range.*.b) or (x >= range.*.c and x <= range.*.d))
                    continue :ticket_validator_loop;
            }

            continue :tickets_loop; // ticket was invalid go next
        }

        var idx: usize = 0;
        var designate_fields_iter = std.mem.splitScalar(u8, ticket, ',');
        while (designate_fields_iter.next()) |x_str| {
            const x = try std.fmt.parseInt(u64, x_str, 10);

            var rvals = ranges.iterator();
            while (rvals.next()) |entry| {
                const range = entry.value_ptr.*;
                if (!((x >= range.a and x <= range.b) or (x >= range.c and x <= range.d))) {
                    _ = range_configuration[idx].remove(entry.key_ptr.*);
                }
            }

            idx += 1;
        }

        try valid_tickets.append(ticket);
    }

    var i: usize = 0;
    var my_ticket_iter = std.mem.splitScalar(u8, my_ticket, ',');
    while (my_ticket_iter.next()) |x_str| {
        defer i += 1;
        var iter = range_configuration[i].keyIterator();
        const key = iter.next().?.*;
        std.debug.print("Index {} is {s}\n", .{ i, key });
        if (std.mem.startsWith(u8, key, "departure")) {
            const x = try std.fmt.parseInt(u64, x_str, 10);
            result *= x;
        }
    }

    defer allocator.free(range_configuration);
    for (range_configuration) |*config| {
        config.*.deinit();
    }
}

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
