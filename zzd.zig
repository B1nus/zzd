const std = @import("std");
const flag_parser = @import("flags.zig");
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut().writer();
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

// ANSI escape codes for coloring
const red = "\x1b[91m";
const bold = "\x1b[1m";
const green = "\x1b[32m";
const yellow = "\x1b[33m";
const reset = "\x1b[0m";

const ReadError = error{
    OutOfMemory,
    OffsetTooFar,
    FileNotFound,
};

// Don't forget to do bytes.deinit()!
pub fn read_all(allocator: std.mem.Allocator, file: std.fs.File, offset: usize, max: ?usize) ReadError!std.ArrayList(u8) {
    const reader = file.reader();
    const max_append_size = max orelse std.math.maxInt(usize);
    var bytes = std.ArrayList(u8).init(allocator);

    reader.skipBytes(offset, .{}) catch {
        return ReadError.OffsetTooFar;
    };

    reader.readAllArrayList(&bytes, max_append_size) catch |e| switch (e) {
        std.mem.Allocator.Error.OutOfMemory => return ReadError.OutOfMemory,
        else => {},
    };

    return bytes;
}

pub fn find_file(path: []const u8) (ReadError || std.fs.File.OpenError)!std.fs.File {
    return std.fs.cwd().openFile(path, .{}) catch |e| switch (e) {
        std.fs.File.OpenError.FileNotFound => return ReadError.FileNotFound,
        else => return e,
    };
}

pub fn zzd_error(description: []const u8) void {
    stdout.print("{s}{s}Error{s}\n{s}zzd{s} {s}. Run " ++ bold ++ "$ zzd -h" ++ reset ++ " for help.\n", .{ red, bold, reset, green, reset, description }) catch {};
    std.process.exit(0);
}

pub fn flag_unwrap(flags: flag_parser.FlagError!flag_parser.Flags) flag_parser.Flags {
    return flags catch |e| {
        switch (e) {
            flag_parser.FlagError.InvalidFlag => zzd_error("can't understand your flag"),
            flag_parser.FlagError.ExpectedFlag => zzd_error("expected a flag"),
            flag_parser.FlagError.UnexpectedNumber => zzd_error("did not expect a number"),
            flag_parser.FlagError.InvalidGroup => zzd_error("can't understand your number after the " ++ bold ++ "-g" ++ reset ++ " flag"),
            flag_parser.FlagError.ExpectedGroup => zzd_error("expected a group number after the " ++ bold ++ "-g" ++ reset ++ " flag"),
            flag_parser.FlagError.InvalidLines => zzd_error("can't understand your number after the " ++ bold ++ "-l" ++ reset ++ " flag"),
            flag_parser.FlagError.ExpectedLines => zzd_error("expected a number after the " ++ bold ++ "-l" ++ reset ++ " flag"),
            flag_parser.FlagError.InvalidColumn => zzd_error("can't understand your number after the " ++ bold ++ "-c" ++ reset ++ " flag"),
            flag_parser.FlagError.TooManyColumns => zzd_error("can't display more than 256 bytes per line"),
            flag_parser.FlagError.ExpectedColumn => zzd_error("expected a column number after the " ++ bold ++ "-c" ++ reset ++ " flag"),
            flag_parser.FlagError.InvalidOffset => zzd_error("can't understand your number after the " ++ bold ++ "-s" ++ reset ++ " flag"),
            flag_parser.FlagError.ExpectedOffset => zzd_error("expected a offset number after the " ++ bold ++ "-s" ++ reset ++ " flag"),
        }
        unreachable;
    };
}

pub fn print_help() void {
    stdout.print(
        \\
        \\{s}zzd{s} is a hex dump utility. Use it to view a files binary data as hex.
        \\
        \\Usage: {s}$ zzd filename{s}
        \\
        \\The available flags are the following
        \\zzd -h                          Print help text.
        \\zzd [filename] -r               Revert hex dump to binary.
        \\zzd [filename] -u               Upper-case hex letters.
        \\zzd [filename] -c [columns]     Bytes per line. Defaults to 16. Max: 256.
        \\zzd [filename] -g [group_size]  Bytes per group. Defaults to 2. Use o to disable grouping.
        \\zzd [filename] -s [offset]      Start dump at byte offset.
        \\zzd [filename] -l [lines]       Stop after dumping bytes.
        \\zzd [filename] -e               Use little endian.
        \\
        \\
    , .{ green, reset, bold, reset }) catch {};
    std.process.exit(0);
}

pub fn main() !void {
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len == 2 and std.mem.eql(u8, args[1], "-h")) {
        print_help();
    }

    var file: std.fs.File = undefined;
    var flags: flag_parser.Flags = undefined;
    if (stdin.isTty()) {
        if (args.len < 2) {
            zzd_error("is missing an input file");
        }

        flags = flag_unwrap(flag_parser.parse_flags(args[2..]));
        file = find_file(args[1]) catch |e| {
            switch (e) {
                ReadError.FileNotFound => zzd_error("can't find file"),
                else => zzd_error("can't read file"),
            }
            unreachable;
        };
    } else {
        if (args.len > 1 and args[1][0] != '-') {
            zzd_error("can't take two inputs at once");
        }
        flags = flag_unwrap(flag_parser.parse_flags(args[1..]));
        file = stdin;
    }

    const max_bytes = flags.lines orelse std.math.maxInt(usize);
    const bytes = try read_all(allocator, file, flags.offset, max_bytes);
    defer _ = bytes.deinit(); // Never forgetti moms spaghetti

    hex_dump(flags, bytes) catch {
        zzd_error("can't print to stdout");
    };
}

pub fn hex_dump(flags: flag_parser.Flags, bytes: std.ArrayList(u8)) !void {
    var lines = std.mem.window(u8, bytes.items, flags.cols, flags.cols);
    var offset = flags.offset;
    // const case = if (flags.upper) std.fmt.Case.upper else std.fmt.Case.lower;
    while (lines.next()) |line| {
        try std.fmt.format(stdout, reset ++ "{x:0>8}: " ++ bold ++ green, .{offset});
        for (line, 0..) |c, i| {
            if (c == 10) try std.fmt.format(stdout, yellow, .{}) else try std.fmt.format(stdout, green, .{});
            if (flags.upper) {
                try std.fmt.format(stdout, "{X:0>2}", .{c});
            } else {
                try std.fmt.format(stdout, "{x:0>2}", .{c});
            }
            if ((i + 1) % flags.group == 0) {
                try std.fmt.format(stdout, " ", .{});
            }
        }
        for (0..flags.cols - line.len + 2) |_| {
            try std.fmt.format(stdout, " ", .{});
        }
        for (line) |c| {
            const new_c: []const u8 = switch (c) {
                '\n', 9, 13 => yellow ++ ".",
                32...126 => green ++ [1]u8{c},
                else => red ++ [1]u8{c},
            };
            try std.fmt.format(stdout, "{s}", .{new_c});
        }
        offset += flags.cols;
        try std.fmt.format(stdout, "\n", .{});
    }
    try stdout.print(reset, .{});
}
