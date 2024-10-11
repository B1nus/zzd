const std = @import("std");
const max_cols = 256;

pub const FlagError = error{
    UnexpectedNumber,
    ExpectedFlag,
    InvalidFlag,
    ExpectedColumn,
    InvalidColumn,
    TooManyColumns,
    ExpectedGroup,
    InvalidGroup,
    ExpectedOffset,
    InvalidOffset,
    ExpectedLines,
    InvalidLines,
};

pub const Flags = struct {
    revert: bool = false,
    upper: bool = false,
    cols: usize = 16,
    group: usize = 2,
    offset: usize = 0,
    lines: ?usize = null,
    little_endian: bool = false,
};

pub fn parse_flags(flag_args: [][:0]u8) FlagError!Flags {
    var flags = Flags{};

    var i: usize = 0;
    while (i < flag_args.len) : (i += 1) {
        if (flag_args[i][0] >= 48 and flag_args[i][0] <= 58) {
            return FlagError.UnexpectedNumber;
        }
        if (flag_args[i][0] == '-') {
            if (flag_args[i].len == 2) {
                switch (flag_args[i][1]) {
                    'r' => flags.revert = true,
                    'u' => flags.upper = true,
                    'e' => flags.little_endian = true,
                    'c' => {
                        flags.cols = try parse_flag_number(flag_args, &i, FlagError.ExpectedColumn, FlagError.InvalidColumn);
                        if (flags.cols > max_cols) {
                            return FlagError.TooManyColumns;
                        }
                    },
                    'g' => flags.group = try parse_flag_number(flag_args, &i, FlagError.ExpectedGroup, FlagError.InvalidGroup),
                    's' => flags.offset = try parse_flag_number(flag_args, &i, FlagError.ExpectedOffset, FlagError.InvalidOffset),
                    'l' => flags.lines = try parse_flag_number(flag_args, &i, FlagError.ExpectedLines, FlagError.InvalidLines),
                    else => return FlagError.InvalidFlag,
                }
            } else {
                return FlagError.InvalidFlag;
            }
        } else {
            return FlagError.ExpectedFlag;
        }
    }

    return flags;
}

pub fn parse_flag_number(flag_args: [][:0]u8, i: *usize, expected: FlagError, invalid: FlagError) FlagError!usize {
    if (flag_args.len >= i.* + 2) {
        i.* += 1;
        switch (flag_args[i.*][0]) {
            '0'...'9' => {
                return std.fmt.parseInt(usize, flag_args[i.*], 10) catch {
                    return invalid;
                };
            },
            '-' => {
                if (flag_args[i.*].len < 2) {
                    return expected;
                }
                switch (flag_args[i.*][1]) {
                    '0'...'9' => return invalid,
                    else => return expected,
                }
            },
            else => {
                return expected;
            },
        }
    } else {
        return expected;
    }
}
