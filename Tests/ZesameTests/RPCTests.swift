import Foundation
import Testing
@testable import Zesame

struct RPCRequestIdGeneratorTests {
    @Test func nextIdIncrementsMonotonically() throws {
        let first = RequestIdGenerator.nextId()
        let second = RequestIdGenerator.nextId()
        let firstInt = try #require(Int(first))
        let secondInt = try #require(Int(second))
        #expect(secondInt == firstInt + 1)
    }

    @Test func nextIdReturnsString() {
        let id = RequestIdGenerator.nextId()
        #expect(!id.isEmpty)
        #expect(Int(id) != nil)
    }
}

struct RPCMethodTests {
    @Test func methodNames() throws {
        let address = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        #expect(RPCMethod.getBalance(address).name == "GetBalance")
        #expect(RPCMethod.getNetworkId.name == "GetNetworkId")
        #expect(RPCMethod.getMinimumGasPrice.name == "GetMinimumGasPrice")
        let txId = "someTxId"
        #expect(RPCMethod.getTransaction(txId).name == "GetTransaction")
    }

    @Test func methodWithNoParams() {
        if case .none = RPCMethod.getNetworkId.params {
            // expected
        } else {
            Issue.record("Expected RPCParams.none for getNetworkId")
        }
        if case .none = RPCMethod.getMinimumGasPrice.params {
            // expected
        } else {
            Issue.record("Expected RPCParams.none for getMinimumGasPrice")
        }
    }

    @Test func methodWithParams() throws {
        let address = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        if case let .positional(values) = RPCMethod.getBalance(address).params {
            #expect(values.count == 1)
        } else {
            Issue.record("Expected positional params for getBalance")
        }

        if case let .positional(values) = RPCMethod.getTransaction("abc123").params {
            #expect(values.count == 1)
        } else {
            Issue.record("Expected positional params for getTransaction")
        }
    }

    @Test func openExtensibility() {
        // The whole point of the redesign: clients add methods in their own modules without
        // editing this library.
        struct DummyResponse: Decodable, Equatable {}
        let custom = RPCMethod<DummyResponse>(name: "Custom", params: .positional([42]))
        #expect(custom.name == "Custom")
    }

    @Test func encodeGetBalanceRequest() throws {
        let address = try LegacyAddress(string: "1234567890123456789012345678901234567890")
        let request = RPCRequest(.getBalance(address))
        #expect(request.method == "GetBalance")
        #expect(request.version == "2.0")
        #expect(!request.requestId.isEmpty)
    }

    @Test func encodeGetNetworkIdRequest() throws {
        let request = RPCRequest(.getNetworkId)
        let data = try JSONEncoder().encode(request)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(json["method"] as? String == "GetNetworkId")
        #expect(json["jsonrpc"] as? String == "2.0")
        #expect(json["id"] != nil)
        #expect(json["params"] == nil)
    }

    @Test func encodeGetTransactionRequest() throws {
        let request = RPCRequest(.getTransaction("tx123"))
        let data = try JSONEncoder().encode(request)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(json["method"] as? String == "GetTransaction")
        let params = json["params"] as? [String]
        #expect(params?.first == "tx123")
    }

    @Test func encodeNamedParams() throws {
        // RPCParams.named is part of the generic core even though Zilliqa doesn't use it.
        let request = RPCRequest(method: "GenericCall", params: .named(["height": 42, "verbose": true]))
        let data = try JSONEncoder().encode(request)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let params = try #require(json["params"] as? [String: Any])
        #expect(params["height"] as? Int == 42)
        #expect(params["verbose"] as? Bool == true)
    }
}

struct RPCRequestTests {
    @Test func versionFieldIsAlwaysTwoZero() {
        let request = RPCRequest(.getNetworkId)
        #expect(request.version == "2.0")
    }

    @Test func directMethodNameInit() {
        let request = RPCRequest(method: "GetBalance", params: .none)
        #expect(request.method == "GetBalance")
        #expect(request.version == "2.0")
    }
}

struct RPCErrorTests {
    @Test func decodeRecognizedError() throws {
        let json = """
        {"id":"1","error":{"code":-32600,"message":"Invalid request"}}
        """
        let data = try #require(json.data(using: .utf8))
        let error = try JSONDecoder().decode(RPCError.self, from: data)
        #expect(error.requestId == "1")
        #expect(error.errorMessage == "Invalid request")
        if case let .recognizedRPCError(code) = error.errorCode {
            #expect(code == .invalidRequest)
        } else {
            Issue.record("Expected recognizedRPCError")
        }
    }

    @Test func decodeUnrecognizedError() throws {
        let json = """
        {"id":"2","error":{"code":9999,"message":"Unknown"}}
        """
        let data = try #require(json.data(using: .utf8))
        let error = try JSONDecoder().decode(RPCError.self, from: data)
        if case let .unrecognizedError(code) = error.errorCode {
            #expect(code == 9999)
        } else {
            Issue.record("Expected unrecognizedError")
        }
    }

    @Test func allRecognizedErrorCodes() throws {
        let cases: [(Int, RPCErrorCodeRecognized)] = [
            (-32600, .invalidRequest),
            (-32601, .methodNotFound),
            (-32602, .invalidParams),
            (-32603, .internalError),
            (-32700, .parseError),
        ]
        for (code, expected) in cases {
            let json = "{\"id\":\"1\",\"error\":{\"code\":\(code),\"message\":\"msg\"}}"
            let data = try #require(json.data(using: .utf8))
            let error = try JSONDecoder().decode(RPCError.self, from: data)
            if case let .recognizedRPCError(c) = error.errorCode {
                #expect(c == expected)
            } else {
                Issue.record("Expected recognizedRPCError for code \(code)")
            }
        }
    }

    @Test func decodeErrorCodeFailure() throws {
        let json = """
        {"id":"3","error":{"code":"notanumber","message":"bad"}}
        """
        let data = try #require(json.data(using: .utf8))
        let error = try JSONDecoder().decode(RPCError.self, from: data)
        if case .failedToParseErrorCode = error.errorCode {
            // expected
        } else {
            Issue.record("Expected failedToParseErrorCode")
        }
    }
}

struct RPCResponseTests {
    @Test func decodeSuccessResponse() throws {
        let json = """
        {"result":"1"}
        """
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(RPCResponse<String>.self, from: data)
        if case let .rpcSuccess(value) = response {
            #expect(value == "1")
        } else {
            Issue.record("Expected rpcSuccess")
        }
    }

    @Test func decodeErrorResponse() throws {
        let json = """
        {"id":"1","error":{"code":-32600,"message":"Invalid request"}}
        """
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(RPCResponse<String>.self, from: data)
        if case .rpcError = response {
            // expected
        } else {
            Issue.record("Expected rpcError")
        }
    }

    @Test func decodeMalformedResponseFallsBackToError() throws {
        let json = """
        {"garbage": true}
        """
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(RPCResponse<String>.self, from: data)
        if case .rpcError = response {
            // expected - malformed goes to rpcError
        } else {
            Issue.record("Expected rpcError for malformed JSON")
        }
    }
}

struct RPCResponseSuccessTests {
    @Test func decodeResult() throws {
        let json = """
        {"result":"hello"}
        """
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(RPCResponseSuccess<String>.self, from: data)
        #expect(response.result == "hello")
    }
}

struct NetworkResponseTests {
    @Test func decodeMainnet() throws {
        let json = "\"1\""
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(NetworkResponse.self, from: data)
        #expect(response.network == .mainnet)
    }

    @Test func decodeTestnet() throws {
        let json = "\"333\""
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(NetworkResponse.self, from: data)
        #expect(response.network == .testnet)
    }
}

struct MinimumGasPriceResponseTests {
    @Test func decodeQaAmount() throws {
        let qaValue = "100000000000"
        let json = "\"\(qaValue)\""
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(MinimumGasPriceResponse.self, from: data)
        #expect(response.amount.qaString == qaValue)
    }
}

struct TransactionReceiptTests {
    @Test func initDirectly() throws {
        let receipt = try TransactionReceipt(id: "txid", totalGasCost: Amount(qa: "1000"))
        #expect(receipt.transactionId == "txid")
    }

    @Test func initFromSentPollResponse() throws {
        let json = """
        {"receipt":{"cumulative_gas":"1","success":true}}
        """
        let data = try #require(json.data(using: .utf8))
        let pollResponse = try JSONDecoder().decode(StatusOfTransactionResponse.self, from: data)
        let receipt = TransactionReceipt(for: "tx1", pollResponse: pollResponse)
        #expect(receipt != nil)
        #expect(receipt?.transactionId == "tx1")
    }

    @Test func initFromFailedPollResponse() throws {
        let json = """
        {"receipt":{"cumulative_gas":"1","success":false}}
        """
        let data = try #require(json.data(using: .utf8))
        let pollResponse = try JSONDecoder().decode(StatusOfTransactionResponse.self, from: data)
        let receipt = TransactionReceipt(for: "tx1", pollResponse: pollResponse)
        #expect(receipt == nil)
    }
}

struct StatusOfTransactionResponseTests {
    @Test func decodeWithSuccess() throws {
        let json = """
        {"receipt":{"cumulative_gas":"50","success":true}}
        """
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(StatusOfTransactionResponse.self, from: data)
        #expect(response.receipt.isSent == true)
    }

    @Test func decodeWithFailure() throws {
        let json = """
        {"receipt":{"cumulative_gas":"50","success":false}}
        """
        let data = try #require(json.data(using: .utf8))
        let response = try JSONDecoder().decode(StatusOfTransactionResponse.self, from: data)
        #expect(response.receipt.isSent == false)
    }
}
