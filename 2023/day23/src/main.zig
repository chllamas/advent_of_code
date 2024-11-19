const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,

    fn hash(self: Coord, num_columns: usize) usize {
        return (self.y * num_columns) + self.x;
    }
};

const Queue = std.DoublyLinkedList(Coord);

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lst = std.ArrayList([]const u8).init(allocator);
    var lines = std.mem.splitScalar(u8, buffer, '\n');
    while (lines.next()) |line| {
        try lst.append(line);
    }

    const graph = try lst.toOwnedSlice();
    defer allocator.free(graph);

    var visited = std.AutoHashMap(usize, bool).init(allocator);
    defer visited.deinit();

    var queue = Queue{};

    // Get first node into the queue
    for (0.., graph[0]) |i, ch| {
        if (ch == '.') {
            const node = try allocator.create(Queue.Node);
            node.*.data = .{ .x = i, .y = 0 };
            queue.append(node);
            break;
        }
    }
}
