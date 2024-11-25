const std = @import("std");

const Position = struct {
    x: i64,
    y: i64,
};

const Sensor = struct {
    position: Position,
    closest_beacon: Position,
};

const test_puzzle: []Sensor = .{
    Sensor{ .position = .{ .x = 2, .y = 18 }, .closest_beacon = .{ .x = -2, .y = 15 } },
    Sensor{ .position = .{ .x = 9, .y = 16 }, .closest_beacon = .{ .x = 10, .y = 16 } },
    Sensor{ .position = .{ .x = 13, .y = 2 }, .closest_beacon = .{ .x = 15, .y = 3 } },
    Sensor{ .position = .{ .x = 12, .y = 14 }, .closest_beacon = .{ .x = 10, .y = 16 } },
    Sensor{ .position = .{ .x = 10, .y = 20 }, .closest_beacon = .{ .x = 10, .y = 16 } },
    Sensor{ .position = .{ .x = 14, .y = 17 }, .closest_beacon = .{ .x = 10, .y = 16 } },
    Sensor{ .position = .{ .x = 8, .y = 7 }, .closest_beacon = .{ .x = 2, .y = 10 } },
    Sensor{ .position = .{ .x = 2, .y = 0 }, .closest_beacon = .{ .x = 2, .y = 10 } },
    Sensor{ .position = .{ .x = 0, .y = 11 }, .closest_beacon = .{ .x = 2, .y = 10 } },
    Sensor{ .position = .{ .x = 20, .y = 14 }, .closest_beacon = .{ .x = 25, .y = 17 } },
    Sensor{ .position = .{ .x = 17, .y = 20 }, .closest_beacon = .{ .x = 21, .y = 22 } },
    Sensor{ .position = .{ .x = 16, .y = 7 }, .closest_beacon = .{ .x = 15, .y = 3 } },
    Sensor{ .position = .{ .x = 14, .y = 3 }, .closest_beacon = .{ .x = 15, .y = 3 } },
    Sensor{ .position = .{ .x = 20, .y = 1 }, .closest_beacon = .{ .x = 15, .y = 3 } },
};

const my_puzzle: []Sensor = .{
    Sensor{ .position = .{ .x = 3291456, .y = 3143280 }, .closest_beacon = .{ .x = 3008934, .y = 2768339 } },
    Sensor{ .position = .{ .x = 3807352, .y = 3409566 }, .closest_beacon = .{ .x = 3730410, .y = 3774311 } },
    Sensor{ .position = .{ .x = 1953670, .y = 1674873 }, .closest_beacon = .{ .x = 2528182, .y = 2000000 } },
    Sensor{ .position = .{ .x = 2820269, .y = 2810878 }, .closest_beacon = .{ .x = 2796608, .y = 2942369 } },
    Sensor{ .position = .{ .x = 3773264, .y = 3992829 }, .closest_beacon = .{ .x = 3730410, .y = 3774311 } },
    Sensor{ .position = .{ .x = 2913793, .y = 2629579 }, .closest_beacon = .{ .x = 3008934, .y = 2768339 } },
    Sensor{ .position = .{ .x = 1224826, .y = 2484735 }, .closest_beacon = .{ .x = 2528182, .y = 2000000 } },
    Sensor{ .position = .{ .x = 1866102, .y = 3047750 }, .closest_beacon = .{ .x = 1809319, .y = 3712572 } },
    Sensor{ .position = .{ .x = 3123635, .y = 118421 }, .closest_beacon = .{ .x = 1453587, .y = -207584 } },
    Sensor{ .position = .{ .x = 2530789, .y = 2254773 }, .closest_beacon = .{ .x = 2528182, .y = 2000000 } },
    Sensor{ .position = .{ .x = 230755, .y = 3415342 }, .closest_beacon = .{ .x = 1809319, .y = 3712572 } },
    Sensor{ .position = .{ .x = 846048, .y = 51145 }, .closest_beacon = .{ .x = 1453587, .y = -207584 } },
    Sensor{ .position = .{ .x = 3505756, .y = 3999126 }, .closest_beacon = .{ .x = 3730410, .y = 3774311 } },
    Sensor{ .position = .{ .x = 2506301, .y = 3745758 }, .closest_beacon = .{ .x = 1809319, .y = 3712572 } },
    Sensor{ .position = .{ .x = 1389843, .y = 957209 }, .closest_beacon = .{ .x = 1453587, .y = -207584 } },
    Sensor{ .position = .{ .x = 3226352, .y = 3670258 }, .closest_beacon = .{ .x = 3730410, .y = 3774311 } },
    Sensor{ .position = .{ .x = 3902053, .y = 3680654 }, .closest_beacon = .{ .x = 3730410, .y = 3774311 } },
    Sensor{ .position = .{ .x = 2573020, .y = 3217129 }, .closest_beacon = .{ .x = 2796608, .y = 2942369 } },
    Sensor{ .position = .{ .x = 3976945, .y = 3871511 }, .closest_beacon = .{ .x = 3730410, .y = 3774311 } },
    Sensor{ .position = .{ .x = 107050, .y = 209321 }, .closest_beacon = .{ .x = 1453587, .y = -207584 } },
    Sensor{ .position = .{ .x = 3931251, .y = 1787536 }, .closest_beacon = .{ .x = 2528182, .y = 2000000 } },
    Sensor{ .position = .{ .x = 1637093, .y = 3976664 }, .closest_beacon = .{ .x = 1809319, .y = 3712572 } },
    Sensor{ .position = .{ .x = 2881987, .y = 1923522 }, .closest_beacon = .{ .x = 2528182, .y = 2000000 } },
    Sensor{ .position = .{ .x = 3059723, .y = 2540501 }, .closest_beacon = .{ .x = 3008934, .y = 2768339 } },
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var capture_hashmap = std.AutoHashMap(i64, bool).init(allocator);
    defer capture_hashmap.deinit();
}
