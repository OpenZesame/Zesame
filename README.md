[![codecov](https://codecov.io/gh/OpenZesame/Zesame/graph/badge.svg?token=8QL8I270E9)](https://codecov.io/gh/OpenZesame/Zesame)

# Zesame

Zesame is an *unofficial* Swift SDK for Zilliqa. It uses the Swift 6.1 toolchain with Swift 5 language mode. This SDK contains cryptographic methods allowing you to create and restore a wallet, sign and broadcast transactions. The cryptographic methods are implemented in [K1](https://github.com/Sajjon/K1) - which uses libsecp256k1. This SDK uses Zilliqas [JSON-RPC API](https://apidocs.zilliqa.com/#introduction)

# Getting started

SPM will install all dependencies, either when run from terminal, or when Xcode gets opened. To run tests it is recommended to use optimisation flag, otherwise it takes quite a bit of time to run them:

```sh
swift test -Xswiftc -O
```

## Protobuf
Zesame uses the JSON-RPC API and not the protobuf API, however, for the packaging of the transaction we need to use protobuf. Please note that protocol buffers is **only** used for the *packaging of the transaction*, it is not used at all for any communication with the API. All data is sent as JSON to the JSON-RPC API.

We use the [apple/swift-protobuf](https://github.com/apple/swift-protobuf) project for protocol buffers, and it is important to note the two different programs associated with swift protobuf:

### Install protobuf
#### `protoc-gen-swift`
This program is used only for generating our swift files from our `.proto` files and we install this program using [brew](https://brew.sh/) (it can also be manually downloaded and built). 

Follow [installation instructions using brew here](https://github.com/apple/swift-protobuf#alternatively-install-via-homebrew). 
```sh
brew install swift-protobuf
```

After this is done we can generate `.pb.swift` files using

```sh
$ protoc --swift_out=. my.proto
```

#### `SwiftProtobuf` library
In order to make use of our generated `.pb.swift` files we need to include the `SwiftProtobuf` library, which is installed through SPM.

### Use protobuf

Stand in the root of the project and run:

```sh
protoc --swift_opt=Visibility=Public --swift_out=. Sources/Zesame/Models/Protobuf/messages.proto
```

Add the generated file `messages.pb.swift` to `Models` folder.

# Dependencies
All dependencies live in [Package.swift](https://github.com/OpenZesame/Zesame/blob/main/Package.swift):

- [K1](https://github.com/Sajjon/K1) — secp256k1 key generation, ECDSA and Schnorr signatures (backed by libsecp256k1).
- [BigInt](https://github.com/attaswift/BigInt) — arbitrary-precision integer math used across amounts and gas.
- [swift-protobuf](https://github.com/apple/swift-protobuf) — only for packaging signed transactions; the wire protocol itself remains JSON-RPC.

Hashing, symmetric crypto, and keystore KDFs are provided by Apple's `CryptoKit` and `CommonCrypto`, so there is no third-party crypto dependency beyond K1.

# API
## Async/await and Combine
The primary surface is `async`/`await` on `ZilliqaService`. A Combine bridge is exposed via `ZilliqaServiceReactive` on types that conform to `CombineCompatible` (including `DefaultZilliqaService`), returning `AnyPublisher<_, Zesame.Error>`.

### Async/await
```swift
let service = DefaultZilliqaService(network: .mainnet)
do {
    let response = try await service.getBalance(for: address)
    print("Balance: \(response.balance)")
} catch {
    print("Failed to get balance, error: \(error)")
}
```

### Combine
```swift
service.combine.getBalance(for: address)
    .sink(
        receiveCompletion: { if case .failure(let error) = $0 { print("Error: \(error)") } },
        receiveValue: { print("Balance: \($0.balance)") }
    )
    .store(in: &cancellables)
```

## Functions
See [ZilliqaService.swift](https://github.com/OpenZesame/Zesame/blob/main/Sources/Zesame/Services/ZilliqaService.swift) for the full surface. A snapshot of the async protocol:
```swift
public protocol ZilliqaService {
    var apiClient: APIClient { get }

    func getNetworkFromAPI() async throws -> NetworkResponse
    func getMinimumGasPrice(alsoUpdateLocallyCachedMinimum: Bool) async throws -> MinimumGasPriceResponse

    func verifyThat(encryptionPassword: String, canDecryptKeystore: Keystore) async throws -> Bool
    func createNewWallet(encryptionPassword: String, kdf: KDF) async throws -> Wallet
    func restoreWallet(from restoration: KeyRestoration) async throws -> Wallet
    func exportKeystore(privateKey: PrivateKey, encryptWalletBy password: String, kdf: KDF) async throws -> Keystore

    func getBalance(for address: LegacyAddress) async throws -> BalanceResponse
    func send(transaction: SignedTransaction) async throws -> TransactionResponse
}
```

# Explorer
While developing it might be useful for you to use the [Zilliqa explorer](http://viewblock.io/zilliqa/)

# Donate
This SDK has been developed by the single author Alexander Cyon without paid salary in his free time - approximately **a thousand hours of work** since May 2018 ([see initial commit](https://github.com/OpenZesame/Zesame/commit/d948741f3e3d38a9962cc9a23552622a303e7ff4)). 

**Any donation would be much appreciated**:

- ZIL: zil108t2jdgse760d88qjqmffhe9uy0nk4wvzx404t
- BTC: 3GarsdAzLpEYbhkryYz1WiZxhtTLLaNJwo
- ETH: 0xAB8F0137295BFE37f50b581F76418518a91ab8DB
- NEO: AbbnnCLP26ccSnLooDDcwPLDnfXbVL5skH

# License

**Zesame** is released under the [MIT License](LICENSE).
