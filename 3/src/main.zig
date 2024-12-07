const std = @import("std");
const expect = std.testing.expect;
const assert = std.debug.assert;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    const stdin = br.reader();

    const input = try stdin.readAllAlloc(allocator, 20000);
    const sum = subMul(input);

    try stdout.print("Sum: {d}\n",.{sum});
    try bw.flush(); // don't forget to flush!
}

pub fn subMul(str: []const u8) u64 {
    var iter = MulIterator{.str = str};
    var sum: u64 = 0;
    while(iter.next()) |m| {
        sum += m.prod();
        std.debug.print("mul({d},{d})\n", .{m.a, m.b});
    }
    return sum;
}

const MulIterator = struct {
    i: usize = 0,
    str: []const u8,
    fn next(self: *MulIterator) ?Mul {
        var i: usize = self.i;
        var res: ?Mul = null;
        while (i < self.str.len) {
            if (self.str[i] != 'm') {i+=1; continue;} i+=1;
            if (self.str[i] != 'u') continue; i+=1;
            if (self.str[i] != 'l') continue; i+=1;
            if (self.str[i] != '(') continue; i+=1;
            //std.debug.print("Parsed mul(\n", .{});
            const intLength = std.mem.indexOf(u8, self.str[i..i + @min(4, self.str.len - 1 - i)], ",") orelse continue;
            if (intLength == 0) continue;
            //std.debug.print("IntLength {d}\n", .{intLength});
            //std.debug.print("Parsing from index {d} to {d}\n", .{i, i + @min(intLength, self.str.len - 1 - i)});
            const d1 = std.fmt.parseInt(u16, self.str[i..i + @min(intLength, self.str.len - i)], 10) catch continue;
            //std.debug.print("Parsed {d}\n", .{d1});
            i+=intLength;

            if (self.str[i] != ',') continue; i+=1;
            //std.debug.print("Parsed ,\n", .{});
            //std.debug.print("i = {d}\n", .{i});
            const intLength2 = std.mem.indexOf(u8, self.str[i..i + @min(4, self.str.len - i)], ")") orelse continue;
            //std.debug.print("IntLength {d}\n", .{intLength2});
            if (intLength2 == 0) continue;
            //std.debug.print("Parsing from index {d} to {d}\n", .{i, i + @min(intLength2, self.str.len - 1 - i)});
            const d2 = std.fmt.parseInt(u16, self.str[i..i + @min(intLength2, self.str.len - 1 - i)], 10) catch continue;
            //std.debug.print("Parsed {d}\n", .{d2});
            i+=intLength2;

            
            if (self.str[i] != ')') continue; i+=1;
            //std.debug.print("Returning {d} {d}\n", .{d1, d2});
            res = Mul{.a = d1, .b = d2};
            break;
        }
        self.i = i;
        return res;
    }
};

pub fn litMatch(str: []const u8, target: u8, i: *usize) ?u8 {
    if (str[i.*] == target) {
        i.* += 1;
        return target;
    } else return null;
}

pub fn digitMatch(str: []const u8, i: *usize) ?u8 {
    if (std.ascii.isDigit(str[i.*])) {
        i.* += 1;
        return str[i.* - 1];
    } else return null;
}

const Mul = struct {
    a:u32 = 0,
    b:u32 = 0,

    pub fn prod(self: *const Mul) u32 {
        return self.a * self.b;
    }
};

//test "parse_mul" {
//    var it = MulIterator{.str = "mul(5,5)adwjiwaj13i< mul(24,dd) mul(23,23)"};
//    var mul = it.next();
//    try expect(mul.?.prod() == 25);
//    mul = it.next();
//    try expect(mul.?.prod() == 23*23);
//}

test "realExample" {
    try expect(subMul("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))") == 161);
}

