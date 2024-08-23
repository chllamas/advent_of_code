const std = @import("std");
const MAP_DIMENSION: usize = 140;
const NO_CONNECTION: usize = 19600;

const Node = struct {
    connection_one: u16,
    connection_two: u16,
    visited: bool,
};

pub fn main() !void {
    var nodes: [19600]Node = undefined;
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReaderSize(MAP_DIMENSION, file.reader());
    var in_stream = buf_reader.reader();

    var idx: usize = 0;
    var buf: [MAP_DIMENSION]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |char| {
            nodes[idx] = switch (char) {
                '.' => .{ NO_CONNECTION, NO_CONNECTION, false },
            };
            idx += 1;
        }
    }
}
