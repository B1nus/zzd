# zzd
zzd is a hex dumper utility made in zig. It's a clone of the [xxd program](https://github.com/vim/vim/blob/master/src/xxd/xxd.c) and the name is from a [Low Level Learning video](https://www.youtube.com/watch?v=pnnx1bkFXng). Consider it my solution to [this coding challenge](https://codingchallenges.fyi/challenges/challenge-xxd/).

> [!NOTE]
> This is not a full clone of xxd. It only implements the basic features of xxd. Also not that zzd does some things differently from xxd. For example: zzd has the same defaults regardless of mode unlike xxd. zzd is not stress tested either, so expect bugs to happen.

# Usage
Use `$ zig build-exe zzd.zig` to build the executable and use `$ ./zzd [filename]` to make a hex dump. Add the `zzd` executable to your Path environment variable to access the program with only `$ zzd`. There are 8 flags available in `zzd`:
```
zzd -h                          Display help message.
zzd [filename] -r               Revert hex dump to binary.
zzd [filename] -u               Upper-case hex letters.
zzd [filename] -c [columns]     Bytes per line. Defaults to 16.
zzd [filename] -g [group_size]  Bytes per group. Defaults to 2.
zzd [filename] -s [offset]      Start dump at byte offset.
zzd [filename] -l [lines]       Stop after dumping lines.
zzd [filename] -e               Use little endian.
```
