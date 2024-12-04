const std = @import("std");

pub fn similarity_sum(a: []u32, b: []u32) u32 {
    std.mem.sort(u32, a, {}, std.sort.asc(u32));
    std.mem.sort(u32, b, {}, std.sort.asc(u32));

    var sum: u32 = 0;
    for (a, 0..) |_, i| {
        const dist = @abs(a[i] - b[i]);
        sum += dist;
    }
    return sum;
}

pub fn similarity_freq(a: []u32, b: []u32, allocator: std.mem.Allocator) !u32 {
    var bh = std.AutoHashMap(u32, u32).init(allocator);

    for (b) |n| {
        try bh.put(n, (bh.get(n) orelse 0) + 1);
    }

    var score: u32 = 0;
    for (a) |n| {
        score += n * (bh.get(n) orelse 0);
    }
    return score;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    const stdin = br.reader();

    var left = std.ArrayList(u32).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(u32).init(allocator);
    defer right.deinit();

    var buf: [15]u8 = undefined;
    while (true) {
        const line = (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) orelse break;
        var it = std.mem.splitScalar(u8, line, ' ');

        // Read the integers
        var count: u8 = 0;
        while (it.next()) |opt_n| {
            const n = std.fmt.parseInt(u32, opt_n, 10) catch continue;
            if (count == 0) {
                try left.append(n);
            } else {
                try right.append(n);
                break;
            }
            count += 1;
        }
    }

    // const sum = similarity_sum(left.items, right.items);
    const score = try similarity_freq(left.items, right.items, allocator);
    try stdout.print("{d}\n", .{score});
    try bw.flush(); // don't forget to flush!
}
