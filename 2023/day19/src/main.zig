const std = @import("std");

const ComparisonResultType = enum { GoTo, Accept, Reject };

const ComparisonResult = union(ComparisonResultType) {
    GoTo: []const u8,
    Accept,
    Reject,
};

const Comparison = struct {
    target: u8,
    val: u32,
    res: ComparisonResult,
};

const RuleType = enum { GreaterThan, LessThan, GoTo, Accept, Reject };

const Rule = union(RuleType) {
    GreaterThan: Comparison,
    LessThan: Comparison,
    GoTo: []const u8,
    Accept,
    Reject,
};

const RuleSetState = enum { processed, unprocessed };

const RuleSet = union(RuleSetState) {
    processed: []Rule,
    unprocessed: []const u8,
};

const Processor = struct {
    allocator: std.mem.Allocator,
    map: std.StringHashMap(RuleSet),

    pub fn process(self: *Processor, key: []const u8) ![]Rule {
        const ruleset = self.map.get(key).?;

        return switch (ruleset) {
            .unprocessed => |str| {
                var lst = std.ArrayList(Rule).init(self.allocator);
                var split_rules = std.mem.splitScalar(u8, str, ',');
                while (split_rules.next()) |rule| {
                    switch (rule[0]) {
                        'A' => try lst.append(Rule{ .Accept = {} }),
                        'R' => try lst.append(Rule{ .Reject = {} }),
                        else => try lst.append(if (std.mem.containsAtLeast(u8, rule, 1, ">"))
                            Rule{ .GreaterThan = try createComparison(rule) }
                        else if (std.mem.containsAtLeast(u8, rule, 1, "<"))
                            Rule{ .LessThan = try createComparison(rule) }
                        else
                            Rule{ .GoTo = rule }),
                    }
                }
                const res = try lst.toOwnedSlice();
                try self.map.put(key, RuleSet{ .processed = res });
                return res;
            },
            .processed => |r| r,
        };
    }
};

fn createComparison(rule: []const u8) !Comparison {
    var iter = std.mem.splitScalar(u8, rule[2..], ':');
    const val = try std.fmt.parseInt(u32, iter.next().?, 10);
    const res = iter.next().?;
    return .{
        .target = rule[0],
        .val = val,
        .res = switch (res[0]) {
            'A' => .{ .Accept = {} },
            'R' => .{ .Reject = {} },
            else => .{ .GoTo = res },
        },
    };
}

fn extractVal(ch: u8, x: u32, m: u32, a: u32, s: u32) u32 {
    return switch (ch) {
        'x' => x,
        'm' => m,
        'a' => a,
        's' => s,
        else => @panic("extractVal() Unknown character"),
    };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lines = std.mem.splitScalar(u8, buffer, '\n');
    var rules = std.StringHashMap(RuleSet).init(allocator);
    defer rules.deinit();
    while (lines.next()) |rule| {
        if (rule.len == 0) break;
        var iter = std.mem.splitScalar(u8, rule, '{');
        const k = iter.next().?;
        const v = iter.next().?;
        try rules.putNoClobber(k, .{ .unprocessed = v[0 .. v.len - 1] });
    }

    var sum: u64 = 0;
    var processor = Processor{ .allocator = allocator, .map = rules };
    parts_loop: while (lines.next()) |line| {
        if (line.len == 0) break;
        var part_vals = std.mem.splitScalar(u8, line[1 .. line.len - 1], ',');
        const x = try std.fmt.parseInt(u32, part_vals.next().?[2..], 10);
        const m = try std.fmt.parseInt(u32, part_vals.next().?[2..], 10);
        const a = try std.fmt.parseInt(u32, part_vals.next().?[2..], 10);
        const s = try std.fmt.parseInt(u32, part_vals.next().?[2..], 10);
        var ruleset = try processor.process("in");
        while (true) {
            for (ruleset) |rule| {
                switch (rule) {
                    .Reject => continue :parts_loop,
                    .Accept => {
                        sum += x + m + a + s;
                        continue :parts_loop;
                    },
                    .GoTo => |key| {
                        ruleset = try processor.process(key);
                        break;
                    },
                    .LessThan => |comp| if (extractVal(comp.target, x, m, a, s) < comp.val) {
                        switch (comp.res) {
                            .Accept => {
                                sum += x + m + a + s;
                                continue :parts_loop;
                            },
                            .Reject => continue :parts_loop,
                            .GoTo => |key| {
                                ruleset = try processor.process(key);
                                break;
                            },
                        }
                    },
                    .GreaterThan => |comp| if (extractVal(comp.target, x, m, a, s) > comp.val) {
                        switch (comp.res) {
                            .Accept => {
                                sum += x + m + a + s;
                                continue :parts_loop;
                            },
                            .Reject => continue :parts_loop,
                            .GoTo => |key| {
                                ruleset = try processor.process(key);
                                break;
                            },
                        }
                    },
                }
            }
        }
    }

    var vals = rules.valueIterator();
    while (vals.next()) |v| switch (v.*) {
        .processed => |t| allocator.free(t),
        else => {},
    };

    std.debug.print("The accepted parts' sum is: {d}\n", .{sum});
}
