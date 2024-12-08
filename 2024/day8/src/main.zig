const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,
};

const AntennaHashMap = std.AutoHashMap(u8, []Coord);

fn addAntenna(hashmap: *AntennaHashMap, key: u8, newCoord: Coord) !void {
    if (hashmap.*.get(key)) |arr| {
        if (hashmap.*.allocator.resize(arr, 1)) {
            arr[arr.len - 1] = newCoord;
        } else {
            var new_arr = try hashmap.*.allocator.alloc(Coord, arr.len + 1);
            std.mem.copyForwards(Coord, new_arr, arr);
            new_arr[new_arr.len - 1] = newCoord;
            hashmap.*.allocator.free(arr);
            try hashmap.*.put(key, new_arr);
        }
    } else {
        var arr = try hashmap.*.allocator.alloc(Coord, 1);
        arr[0] = newCoord;
        try hashmap.*.putNoClobber(key, arr);
    }
}

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

    var antennas = AntennaHashMap.init(allocator);
    try addAntenna(&antennas, 'a', .{ .x = 0, .y = 1 });
    try addAntenna(&antennas, 'a', .{ .x = 2, .y = 12 });
    try addAntenna(&antennas, 'b', .{ .x = 2, .y = 12 });
    try addAntenna(&antennas, 'a', .{ .x = 5, .y = 3 });

    var iter = antennas.iterator();
    while (iter.next()) |entry| {
        std.debug.print("{} | ", .{entry.key_ptr.*});
        for (entry.value_ptr.*) |v| {
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
