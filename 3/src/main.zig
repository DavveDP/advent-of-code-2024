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
    const sum = subMulDoDont(input[0..]);

    try stdout.print("Sum: {d}\n",.{sum});
    try bw.flush(); // don't forget to flush!
}

pub fn subMulDoDont(str: []const u8) u64 {

    var mul = MulIterator{.str = str};
    var do = DoIterator{.str = str};
    var dont = DontIterator{.str = str};
    var sum: u64 = 0;
    
    while(mul.i < str.len - 1) {
        _ = dont.next();
        while(mul.next(dont.i)) |m| {
            sum += m.prod();
        }
        do.i = dont.i;
        _ = do.next();
        mul.i = do.i;
    }
    return sum;
}

pub fn subMul(str: []const u8) u64 {
    var mul = MulIterator{.str = str[0..]};
    var sum: u64 = 0;
    while(mul.next(str.len)) |m| {
        sum += m.prod();
        //std.debug.print("mul({d},{d})\n", .{m.a, m.b});
    }
    return sum;
}

const DoIterator = struct {
    i: usize = 0,
    str: []const u8,
    fn next(self: *DoIterator) ?bool {
        while (self.i < self.str.len) {
            if (self.str[self.i] != 'd') {self.i+=1; continue;} self.i+=1;
            if (self.str[self.i] != 'o') continue; self.i+=1;
            if (self.str[self.i] != '(') continue; self.i+=1;
            if (self.str[self.i] != ')') continue; self.i+=1;
            return true;
        }
        return null;
    }
};

const DontIterator = struct {
    i: usize = 0,
    str: []const u8,
    fn next(self: *DontIterator) ?bool {
        while (self.i < self.str.len) {
            if (self.str[self.i] != 'd') {self.i+=1; continue;} self.i+=1;
            if (self.str[self.i] != 'o') continue; self.i+=1;
            if (self.str[self.i] != 'n') continue; self.i+=1;
            if (self.str[self.i] != '\'') continue; self.i+=1;
            if (self.str[self.i] != 't') continue; self.i+=1;
            if (self.str[self.i] != '(') continue; self.i+=1;
            if (self.str[self.i] != ')') continue; self.i+=1;
            return true;
        }
        return null;
    }
};

const MulIterator = struct {
    i: usize = 0,
    str: []const u8,
    fn next(self: *MulIterator, max: usize) ?Mul {
        while (self.i < self.str.len and self.i < max) {
            if (self.str[self.i] != 'm') {self.i+=1; continue;} self.i+=1;
            if (self.str[self.i] != 'u') continue; self.i+=1;
            if (self.str[self.i] != 'l') continue; self.i+=1;
            if (self.str[self.i] != '(') continue; self.i+=1;
            //std.debug.print("Parsed mul(\n", .{});
            const intLength = std.mem.indexOf(
                u8, 
                self.str[self.i..self.i + @min(4, self.str.len - 1 - self.i)],
                ",") 
                orelse continue;
            if (intLength == 0) continue;
            //std.debug.print("IntLength {d}\n", .{intLength});
            //std.debug.print("Parsing from index {d} to {d}\n", .{i, i + @min(intLength, self.str.len - 1 - i)});
            const d1 = std.fmt.parseInt(
                u16, 
                self.str[self.i..self.i + @min(intLength, self.str.len - self.i)],
                10) 
                catch continue;
            //std.debug.print("Parsed {d}\n", .{d1});
            self.i+=intLength;

            if (self.str[self.i] != ',') continue; self.i+=1;
            //std.debug.print("Parsed ,\n", .{});
            //std.debug.print("i = {d}\n", .{i});
            const intLength2 = std.mem.indexOf(
                u8, 
                self.str[self.i..self.i + @min(4, self.str.len - self.i)],
                ")") 
                orelse continue;
            //std.debug.print("IntLength {d}\n", .{intLength2});
            if (intLength2 == 0) continue;
            //std.debug.print("Parsing from index {d} to {d}\n", .{i, i + @min(intLength2, self.str.len - 1 - i)});
            const d2 = std.fmt.parseInt(
                u16, 
                self.str[self.i..self.i + @min(intLength2, self.str.len - 1 - self.i)],
                10) 
                catch continue;
            //std.debug.print("Parsed {d}\n", .{d2});
            self.i+=intLength2;


            if (self.str[self.i] != ')') continue; self.i+=1;
            //std.debug.print("Returning {d} {d}\n", .{d1, d2});
            return Mul{.a = d1, .b = d2};
        }
        return null;
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
//

const OneStarInput = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const TwoStarInput = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

test "1star" {
    try expect(subMul(OneStarInput) == 161);
}

test "DoIter" {
    var do = DoIterator{.str = TwoStarInput};
    const first = do.next();
    const second = do.next();
    try expect(do.i == TwoStarInput.len);
    try expect(first.?);
    try expect(second == null);
}

test "DontIter" {
    var dont = DontIterator{.str = TwoStarInput};
    const first = dont.next();
    const second = dont.next();
    try expect(dont.i == TwoStarInput.len);
    try expect(first.?);
    try expect(second == null);
}

test "2star" {
    try expect(subMulDoDont(TwoStarInput) == 48);
}

