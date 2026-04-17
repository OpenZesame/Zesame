import Foundation

enum RIPEMD160 {
    static func hash(message: [UInt8]) throws -> [UInt8] {
        var ctx = Context()
        ctx.update(message)
        return ctx.finalize()
    }
}

private struct Context {
    private var state: (UInt32, UInt32, UInt32, UInt32, UInt32)
    private var count: UInt64
    private var buffer: [UInt8]

    init() {
        state = (0x6745_2301, 0xEFCD_AB89, 0x98BA_DCFE, 0x1032_5476, 0xC3D2_E1F0)
        count = 0
        buffer = []
    }

    mutating func update(_ input: [UInt8]) {
        buffer.append(contentsOf: input)
        count += UInt64(input.count)
        while buffer.count >= 64 {
            let block = Array(buffer.prefix(64))
            buffer = Array(buffer.dropFirst(64))
            compress(block)
        }
    }

    mutating func finalize() -> [UInt8] {
        var final = buffer
        let bitCount = count * 8
        final.append(0x80)
        while final.count % 64 != 56 {
            final.append(0x00)
        }
        for i in 0 ..< 8 {
            final.append(UInt8((bitCount >> (8 * i)) & 0xFF))
        }
        while final.count >= 64 {
            let block = Array(final.prefix(64))
            final = Array(final.dropFirst(64))
            compress(block)
        }
        var out = [UInt8](repeating: 0, count: 20)
        for (i, s) in [state.0, state.1, state.2, state.3, state.4].enumerated() {
            out[4 * i] = UInt8(s & 0xFF)
            out[4 * i + 1] = UInt8((s >> 8) & 0xFF)
            out[4 * i + 2] = UInt8((s >> 16) & 0xFF)
            out[4 * i + 3] = UInt8((s >> 24) & 0xFF)
        }
        return out
    }

    private mutating func compress(_ block: [UInt8]) {
        func w(_ b: [UInt8], _ i: Int) -> UInt32 {
            UInt32(b[4 * i]) | UInt32(b[4 * i + 1]) << 8 | UInt32(b[4 * i + 2]) << 16 | UInt32(b[4 * i + 3]) << 24
        }
        let X = (0 ..< 16).map { w(block, $0) }
        var (al, bl, cl, dl, el) = state
        var (ar, br, cr, dr, er) = state

        func rol(_ x: UInt32, _ n: UInt32) -> UInt32 {
            (x << n) | (x >> (32 - n))
        }
        func f0(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            x ^ y ^ z
        }
        func f1(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            (x & y) | (~x & z)
        }
        func f2(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            (x | ~y) ^ z
        }
        func f3(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            (x & z) | (y & ~z)
        }
        func f4(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            x ^ (y | ~z)
        }

        let rl: [Int] = [
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            7,
            4,
            13,
            1,
            10,
            6,
            15,
            3,
            12,
            0,
            9,
            5,
            2,
            14,
            11,
            8,
            3,
            10,
            14,
            4,
            9,
            15,
            8,
            1,
            2,
            7,
            0,
            6,
            13,
            11,
            5,
            12,
            1,
            9,
            11,
            10,
            0,
            8,
            12,
            4,
            13,
            3,
            7,
            15,
            14,
            5,
            6,
            2,
            4,
            0,
            5,
            9,
            7,
            12,
            2,
            10,
            14,
            1,
            3,
            8,
            11,
            6,
            15,
            13,
        ]
        let rr: [Int] = [
            5,
            14,
            7,
            0,
            9,
            2,
            11,
            4,
            13,
            6,
            15,
            8,
            1,
            10,
            3,
            12,
            6,
            11,
            3,
            7,
            0,
            13,
            5,
            10,
            14,
            15,
            8,
            12,
            4,
            9,
            1,
            2,
            15,
            5,
            1,
            3,
            7,
            14,
            6,
            9,
            11,
            8,
            12,
            2,
            10,
            0,
            4,
            13,
            8,
            6,
            4,
            1,
            3,
            11,
            15,
            0,
            5,
            12,
            2,
            13,
            9,
            7,
            10,
            14,
            12,
            15,
            10,
            4,
            1,
            5,
            8,
            7,
            6,
            2,
            13,
            14,
            0,
            3,
            9,
            11,
        ]
        let sl: [UInt32] = [
            11,
            14,
            15,
            12,
            5,
            8,
            7,
            9,
            11,
            13,
            14,
            15,
            6,
            7,
            9,
            8,
            7,
            6,
            8,
            13,
            11,
            9,
            7,
            15,
            7,
            12,
            15,
            9,
            11,
            7,
            13,
            12,
            11,
            13,
            6,
            7,
            14,
            9,
            13,
            15,
            14,
            8,
            13,
            6,
            5,
            12,
            7,
            5,
            11,
            12,
            14,
            15,
            14,
            15,
            9,
            8,
            9,
            14,
            5,
            6,
            8,
            6,
            5,
            12,
            9,
            15,
            5,
            11,
            6,
            8,
            13,
            12,
            5,
            12,
            13,
            14,
            11,
            8,
            5,
            6,
        ]
        let sr: [UInt32] = [
            8,
            9,
            9,
            11,
            13,
            15,
            15,
            5,
            7,
            7,
            8,
            11,
            14,
            14,
            12,
            6,
            9,
            13,
            15,
            7,
            12,
            8,
            9,
            11,
            7,
            7,
            12,
            7,
            6,
            15,
            13,
            11,
            9,
            7,
            15,
            11,
            8,
            6,
            6,
            14,
            12,
            13,
            5,
            14,
            13,
            13,
            7,
            5,
            15,
            5,
            8,
            11,
            14,
            14,
            6,
            14,
            6,
            9,
            12,
            9,
            12,
            5,
            15,
            8,
            8,
            5,
            12,
            9,
            12,
            5,
            14,
            6,
            8,
            13,
            6,
            5,
            15,
            13,
            11,
            11,
        ]
        let kl: [UInt32] = Array(repeating: 0x0000_0000, count: 16) +
            Array(repeating: 0x5A82_7999, count: 16) +
            Array(repeating: 0x6ED9_EBA1, count: 16) +
            Array(repeating: 0x8F1B_BCDC, count: 16) +
            Array(repeating: 0xA953_FD4E, count: 16)
        let kr: [UInt32] = Array(repeating: 0x50A2_8BE6, count: 16) +
            Array(repeating: 0x5C4D_D124, count: 16) +
            Array(repeating: 0x6D70_3EF3, count: 16) +
            Array(repeating: 0x7A6D_76E9, count: 16) +
            Array(repeating: 0x0000_0000, count: 16)

        for j in 0 ..< 80 {
            let fl: UInt32
            let fr: UInt32
            switch j {
            case 0 ..< 16: fl = f0(bl, cl, dl); fr = f4(br, cr, dr)
            case 16 ..< 32: fl = f1(bl, cl, dl); fr = f3(br, cr, dr)
            case 32 ..< 48: fl = f2(bl, cl, dl); fr = f2(br, cr, dr)
            case 48 ..< 64: fl = f3(bl, cl, dl); fr = f1(br, cr, dr)
            default: fl = f4(bl, cl, dl); fr = f0(br, cr, dr)
            }
            var t = rol(al &+ fl &+ X[rl[j]] &+ kl[j], sl[j]) &+ el
            al = el; el = dl; dl = rol(cl, 10); cl = bl; bl = t
            t = rol(ar &+ fr &+ X[rr[j]] &+ kr[j], sr[j]) &+ er
            ar = er; er = dr; dr = rol(cr, 10); cr = br; br = t
        }

        let t = state.1 &+ cl &+ dr
        state.1 = state.2 &+ dl &+ er
        state.2 = state.3 &+ el &+ ar
        state.3 = state.4 &+ al &+ br
        state.4 = state.0 &+ bl &+ cr
        state.0 = t
    }
}
