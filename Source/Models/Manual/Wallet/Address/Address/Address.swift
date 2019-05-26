// 
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public enum Address: AddressChecksummedConvertible {

    case checksummed(AddressChecksummed)
    case notNecessarilyChecksummed(AddressNotNecessarilyChecksummed)

}

public extension Address {
    
    init(string: String) throws {
        
        do {
            let bech32 = try Bech32Address(bech32String: string)
            
            func inner(bech32Address: Bech32Address) throws -> Address {
                
                let expecetedLength = Style.bech32.expectedLength
                guard let relevantInfoPart = bech32Address.dataPart.excludingChecksum else {
                    throw Error.bech32DataEmpty
                }
                
                let length = relevantInfoPart.asString.count
                guard length == expecetedLength else {
                    throw Error.incorrectLength(expectedLength: expecetedLength, forStyle: Style.bech32, butGot: length)
                }
                let addressAsData = try Bech32.convertbits(data: relevantInfoPart.data.bytes, fromBits: 5, toBits: 8, pad: false)
                let hexString = try HexString(addressAsData.toHexString())
                let ethStyleNotNecessarilyChecksummed = try AddressNotNecessarilyChecksummed(hexString: hexString)
                return Address.checksummed(ethStyleNotNecessarilyChecksummed.checksummedAddress)
            }
            self = try inner(bech32Address: bech32)
        } catch {
            let hexString = try HexString(string)
            self = .checksummed(try AddressChecksummed(hexString: hexString))
        }
        
        
    }
    
}

