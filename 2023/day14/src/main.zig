const std = @import("std");

fn shift_graph(graph: [][]u8) void {
    for (0.., graph) |y, *row| {
        for (0.., row.*) |x, ch| {
            if (ch == 'O') {
                var height = y;
                while (height > 0 and graph[height - 1][x] == '.') : (height -= 1) {}
                if (height != y) {
                    graph[height][x] = 'O';
                    graph[y][x] = '.';
                }
            }
        }
    }
}

fn print_graph(graph: *const [][]u8) void {
    for (graph.*) |*row| {
        std.debug.print("{s}\n", .{row.*});
    }
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var list = std.ArrayList([]u8).init(allocator);
    var iter = std.mem.splitScalar(u8, buffer, '\n');
    var cur = iter.next();
    while (cur != null) : (cur = iter.next()) {
        const arr = try allocator.dupe(u8, cur.?);
        try list.append(arr);
    }

    const graph = try list.toOwnedSlice();
    list.deinit();

    shift_graph(graph);

    print_graph(&graph);
}
