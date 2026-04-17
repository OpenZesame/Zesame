import Foundation
import Testing
@testable import Zesame

struct NetworkDecodeTests {
    @Test func decodeMainnet() throws {
        let json = "\"1\""
        let data = try #require(json.data(using: .utf8))
        let network = try JSONDecoder().decode(Network.self, from: data)
        #expect(network == .mainnet)
    }

    @Test func decodeTestnet() throws {
        let json = "\"333\""
        let data = try #require(json.data(using: .utf8))
        let network = try JSONDecoder().decode(Network.self, from: data)
        #expect(network == .testnet)
    }

    @Test func decodeUnknownChainId() throws {
        let json = "\"999\""
        let data = try #require(json.data(using: .utf8))
        #expect(throws: (any Swift.Error).self) {
            _ = try JSONDecoder().decode(Network.self, from: data)
        }
    }

    @Test func decodeInvalidString() throws {
        let json = "\"notanumber\""
        let data = try #require(json.data(using: .utf8))
        #expect(throws: (any Swift.Error).self) {
            _ = try JSONDecoder().decode(Network.self, from: data)
        }
    }

    @Test func defaultNetwork() {
        #expect(Network.default == .mainnet)
    }

    @Test func chainId() {
        #expect(Network.mainnet.chainId == 1)
        #expect(Network.testnet.chainId == 333)
    }

    @Test func baseURL() {
        #expect(Network.mainnet.baseURL == ZilliqaAPIEndpoint.mainnet.baseURL)
        #expect(Network.testnet.baseURL == ZilliqaAPIEndpoint.testnet.baseURL)
    }
}

struct ZilliqaAPIEndpointTests {
    @Test func mainnetBaseURL() {
        let url = ZilliqaAPIEndpoint.mainnet.baseURL
        #expect(url.absoluteString == "https://api.zilliqa.com")
    }

    @Test func netBaseURL() {
        let url = ZilliqaAPIEndpoint.testnet.baseURL
        #expect(url.absoluteString == "https://dev-api.zilliqa.com")
    }
}

struct VersionTests {
    @Test func initWithValue() {
        let v = Version(value: 65537)
        #expect(v.value == 65537)
    }

    @Test func initWithNetwork() {
        let v = Version(network: .mainnet, transactionVersion: 1)
        #expect(v.value == (1 << 16) + 1)
        #expect(v.value == 65537)
    }

    @Test func initWithTestnet() {
        let v = Version(network: .testnet, transactionVersion: 1)
        #expect(v.value == (333 << 16) + 1)
    }

    @Test func integerLiteral() {
        let v: Version = 65537
        #expect(v.value == 65537)
    }

    @Test func equatable() {
        let v1 = Version(value: 1)
        let v2 = Version(value: 1)
        let v3 = Version(value: 2)
        #expect(v1 == v2)
        #expect(v1 != v3)
    }

    @Test func encode() throws {
        let v = Version(value: 65537)
        let data = try JSONEncoder().encode(v)
        let decoded = try JSONDecoder().decode(UInt32.self, from: data)
        #expect(decoded == 65537)
    }

    @Test func decode() throws {
        let data = try JSONEncoder().encode(UInt32(65537))
        let v = try JSONDecoder().decode(Version.self, from: data)
        #expect(v.value == 65537)
    }
}

struct DefaultZilliqaServiceInitTests {
    @Test func initWithEndpoint() {
        let service = DefaultZilliqaService(endpoint: .mainnet)
        #expect(service.apiClient is DefaultAPIClient)
    }

    @Test func initWithNetwork() {
        let service = DefaultZilliqaService(network: .mainnet)
        #expect(service.apiClient is DefaultAPIClient)
    }

    @Test func initWithTestnet() {
        let service = DefaultZilliqaService(endpoint: .testnet)
        #expect(service.apiClient is DefaultAPIClient)
    }

    @Test func defaultAPIClientBaseURL() {
        let client = DefaultAPIClient(endpoint: .mainnet)
        #expect(client.baseURL == ZilliqaAPIEndpoint.mainnet.baseURL)
    }

    @Test func defaultAPIClientBaseURLFromURL() throws {
        let url = try #require(URL(string: "https://example.com"))
        let client = DefaultAPIClient(baseURL: url)
        #expect(client.baseURL == url)
    }
}
