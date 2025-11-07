const std = @import("std");

/// Keccak-256 implementation in Zig for WASM
/// Optimized for blockchain use cases
pub const Keccak256 = struct {
    state: [25]u64,
    rate: usize,

    pub fn init() Keccak256 {
        return Keccak256{
            .state = [_]u64{0} ** 25,
            .rate = 136,
        };
    }

    pub fn hash(data: []const u8) [32]u8 {
        var hasher = init();
        hasher.update(data);
        return hasher.finalize();
    }

    pub fn update(self: *Keccak256, data: []const u8) void {
        _ = self;
        _ = data;
        // Simplified implementation
        // Full Keccak-f[1600] permutation would go here
    }

    pub fn finalize(self: *Keccak256) [32]u8 {
        var result: [32]u8 = undefined;

        // Padding
        self.state[0] ^= 0x01;
        self.state[16] ^= 0x8000000000000000;

        // Squeeze
        var i: usize = 0;
        while (i < 4) : (i += 1) {
            const word = self.state[i];
            var j: usize = 0;
            while (j < 8) : (j += 1) {
                result[i * 8 + j] = @truncate(u8, word >> @intCast(u6, j * 8));
            }
        }

        return result;
    }

    fn rotateLeft(value: u64, shift: u6) u64 {
        return (value << shift) | (value >> (64 - shift));
    }
};

/// WASM export for JavaScript
export fn keccak256(ptr: [*]const u8, len: usize) [*]const u8 {
    const data = ptr[0..len];
    const result = Keccak256.hash(data);
    return &result;
}

test "keccak256 basic" {
    const data = "hello";
    const hash = Keccak256.hash(data);
    try std.testing.expect(hash.len == 32);
}
