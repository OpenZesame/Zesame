//
//  Address+Validation.swift
//  Zesame
//
//  Created by Alexander Cyon on 2018-10-21.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import EllipticCurveKit

public extension Address {

    public enum Error: Swift.Error {
        case tooLong
        case tooShort
        case containsInvalidCharacters
    }

    // Checksums a Zilliqa address, implementation is based on Javascript library:
    // https://github.com/Zilliqa/Zilliqa-JavaScript-Library/blob/9368fb34a0d443797adc1ecbcb9728db9ce75e97/packages/zilliqa-js-crypto/src/util.ts#L76-L96
    static func checksum(address hex: HexString) -> String {
        let numberFromHash = EllipticCurveKit.Crypto.hash(Data(hex: hex), function: HashFunction.sha256).asNumber
        let address = hex.lowercased().droppingLeading0x()
        var checksummed = ""
        for (i, character) in address.enumerated() {
            let string = String(character)
            let characterIsLetter = CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: string))
            guard characterIsLetter else {
                checksummed += string
                continue
            }
            let andOperand: Number = Number(2).power(255 - 6 * i)
            let shouldUppercase = (numberFromHash & andOperand) >= 1
            checksummed += shouldUppercase ? string.uppercased() : string.lowercased()
        }
        return checksummed
    }

    static func isAddressChecksummed(_ address: HexString) -> Bool {
        guard
            address.isAddress,
            case let checksummed = checksum(address: address),
            checksummed == address || checksummed == address.droppingLeading0x()
            else { return false }
        return true
    }

    static func isValidAddress(hexString: HexString) -> Bool {
        do {
            try validateAddress(hexString: hexString)
            return true
        } catch {
            return false
        }
    }
    static func validateAddress(hexString: HexString) throws {
        let hex = hexString.droppingLeading0x()
        if hex.count < lengthOfValidAddresses {
            throw Error.tooShort
        }
        if hex.count > lengthOfValidAddresses {
            throw Error.tooLong
        }
        if Number(hexString: hex) == nil {
            throw Error.containsInvalidCharacters
        }
        // is valid
    }
}
