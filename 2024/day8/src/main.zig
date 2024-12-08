const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,
};

const AntennaHashMap = std.AutoHashMap(u8, std.ArrayList(Coord));

const AntennaList = struct {
    antennas: *AntennaHashMap,

    fn addAntenna(self: *AntennaList, key: u8, newCoord: Coord) !void {
        if (self.*.antennas.*.get(key)) |*arr| {
            try arr.*.append(newCoord);
        } else {
            try self.*.antennas.*.put(key, std.ArrayList(Coord).init(self.*.antennas.allocator));
            try self.*.addAntenna(key, newCoord);
        }
    }
};

fn createGraph(allocator: std.mem.Allocator, buffer: []const u8) ![]const []const u8 {
    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }
    return try list.toOwnedSlice();
}

fn part1(allocator: std.mem.Allocator, buffer: []const u8) !void {
    const graph = try createGraph(allocator, buffer);
    defer allocator.free(graph);

    var hashmap = AntennaHashMap.init(allocator);
    var antennas = AntennaList{ .antennas = &hashmap };
    try antennas.addAntenna('a', .{ .x = 0, .y = 1 });
    try antennas.addAntenna('a', .{ .x = 2, .y = 12 });
    try antennas.addAntenna('b', .{ .x = 2, .y = 12 });
    try antennas.addAntenna('a', .{ .x = 5, .y = 3 });

    var iter = antennas.antennas.iterator();
    while (iter.next()) |entry| {
        std.debug.print("{} | ", .{entry.key_ptr.*});
        for (entry.value_ptr.*.items) |v| {
            std.debug.print("({}, {}) ", .{ v.x, v.y });
        }
        std.debug.print("\n", .{});
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    try part1(allocator, buffer);
}
