//
//  Wallet.swift
//  ZilliqaSDK
//
//  Created by Alexander Cyon on 2018-05-25.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import EllipticCurve

//public typealias PublicKey = Secp256k1

public extension BigUInt {
    func toHexString() -> String {
        return String(self, radix: 16)
    }
}

func uint8ArrayToData(_ array: [UInt8]) -> Data {
    fatalError()
}

public struct PublicKey {

    public enum Format {
        case compressed
        case uncompressed

        public var prefixByte: UInt8 {
            switch self {
            case .uncompressed: return 0x4
            case .compressed: return 0x2
            }
        }
    }

    public let publicKey: [UInt8]
    public let format: Format

    public init(privateKey: PrivateKey, format: Format = .uncompressed) {
        fatalError()
//        let publicKeyCurvePoint = privateKey.randomBigNumber * Secp256k1.Generator
//        guard let publicKeyCurvePointYWrapper = publicKeyCurvePoint.y else { fatalError("should have Y value") }
//        let publicKeyCurvePointY: BigNumber = publicKeyCurvePointYWrapper.value
//        let publicKeyCurvePointX: BigNumber = publicKeyCurvePoint.x.value
//
//        let xAsUInt8Array = publicKeyCurvePointX.exportToUInt8Array()
//        let yAsUInt8Array = publicKeyCurvePointY.exportToUInt8Array()
//
//        guard xAsUInt8Array.count == 32, yAsUInt8Array.count == xAsUInt8Array.count else { fatalError("wrong length, should be 32") }
//
//        let keyData: [UInt8]
//
//        switch format {
//        case .compressed:
//            // TODO: VERIFY use `last` instead of `first`?? LSB or MSB? :S
//            let relevantByteFromPointY: UInt8 = publicKeyCurvePointY.exportToUInt8Array().first!
//            let one = UInt8(1)
//            let logicalAndResult: UInt8 = relevantByteFromPointY & one
//            let prefix: UInt8 = 0x2 + logicalAndResult
//            keyData = [prefix] + xAsUInt8Array
//            guard keyData.count == 33 else { fatalError("incorrect length, should be 33") }
//        case .uncompressed:
//            keyData = [UInt8(4)] + xAsUInt8Array + yAsUInt8Array
//            guard keyData.count == 65 else { fatalError("incorrect length, should be 65") }
//        }
//
//        self.publicKey = keyData
//        self.format = format
    }
}

func sizeof<T:FixedWidthInteger>(_ int: T) -> Int {
    return int.bitWidth/UInt8.bitWidth
}

func sizeof<T:FixedWidthInteger>(_ intType: T.Type) -> Int {
    return intType.bitWidth/UInt8.bitWidth
}

func integerWithBytes<T: UnsignedInteger & FixedWidthInteger>(bytes: [UInt8]) -> T? {

    let size = sizeof(T.self)

    if bytes.count < size {
        return nil
    }

    var acc: UIntMax = 0
    for i in 0..<size {
        acc |= bytes[i].toUIntMax() << UIntMax(i * 8)

    }
    // UnsignedInteger defines init(_: UIntMax)
    return T(acc)
}

public extension PublicKey {

    func as8array() -> [UInt8] {
        return publicKey
    }

    func as64array() -> [UInt] {
        let as8Array = as8array()

        let uint8PerUint64 = 4

        guard as8Array.count % uint8PerUint64 == 0 else { fatalError("bad length") }

        let newCount = as8Array.count / uint8PerUint64

        var array = Array<UInt>(reserveCapacity: newCount)

        for i in 0..<newCount {
            let subrange = Array<UInt8>(as8Array[i...i+uint8PerUint64])
            let element: UInt = integerWithBytes(bytes: subrange)!
            array[i] = element
        }
        return array
    }

    func asBigNumber() -> BigNumber {
        let array = as64array()
        return BigNumber(words: array)
    }

    func toHexString() -> String {
        let bigNumber = asBigNumber()
        return bigNumber.toHexString()
    }
}

public struct KeyPair {
    public let privateKey: PrivateKey
    public let publicKey: PublicKey

    public init(privateKey: PrivateKey, publicKeyFormat: PublicKey.Format = .uncompressed) {
        self.privateKey = privateKey
        self.publicKey = PublicKey(privateKey: privateKey, format: publicKeyFormat)
    }
}

public struct Wallet {
    public let keyPair: KeyPair
    public let address: Address // calculated from public key
    public let balance: Amount
    public let nonce: Nonce

    init(keyPair: KeyPair, balance: Amount = .zero, nonce: Nonce = .zero) {
        self.keyPair = keyPair
        self.address = Address(publicKey: keyPair.publicKey)
        self.balance = balance
        self.nonce = nonce
    }
}

