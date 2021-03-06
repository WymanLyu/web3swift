//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Contract protocol
/// At this moment uses only in ContractV2
public protocol ContractProtocol {
    
    /// Contract address
    var address: Address? { get set }
    
    /// Default sending options
    var options: Web3Options { get set }
    
    /// Contract methods
    var allMethods: [String] { get }
    
    /// Contract events
    var allEvents: [String] { get }
    
    /// Deploys contract with bytecode and init parameters
    /// - parameter bytecode: Contract bytecode
    /// - parameter parameters: Contract init arguments
    /// - parameter extraData: Extra data for transaction
    /// - parameter options: Transaction options
    func deploy(bytecode: Data, parameters: [Any], extraData: Data, options: Web3Options?) throws -> EthereumTransaction
    
    /// Converts method to EthereumTransaction that you can call or send later
    /// - parameter method: Contract function name
    /// - parameter parameters: Function arguments
    /// - parameter extraData: Extra data for transaction
    /// - parameter options: Transaction options
    /// - returns: Prepared transaction
    func method(_ method: String, parameters: [Any], extraData: Data, options: Web3Options?) throws -> EthereumTransaction
    
    /// init for deployed contract
    init(_ abiString: String, at address: Address?) throws
    
    /// Decodes smart contract response to dictionary
    /// - parameter method: Smart contract function name
    /// - parameter data: Smart contract response data
    func decodeReturnData(_ method: String, data: Data) -> [String: Any]?
    
    /// Decodes input arguments to dictionary
    /// - parameter method: Smart contract function name
    /// - parameter data: Smart contract input data
    func decodeInputData(_ method: String, data: Data) -> [String: Any]?
    
    /// Searches for smart contract method and decodes input arguments to dictionary
    /// - parameter data: Smart contract input data
    func decodeInputData(_ data: Data) -> [String: Any]?
    
    /// Parses event from log to name and dictionary data
    /// - parameter eventLog: Raw event log
    func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?)
    /// Tests event with filter
    func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool?
//    func allEvents() -> [String: [String: Any]?]
}

/// Protocol that adds comparable function
public protocol EventFilterComparable {
    /// Returns true if self is equal ot other
    func isEqualTo(_ other: AnyObject) -> Bool
}

/// Event Filter encodable functions
public protocol EventFilterEncodable {
    /// Encodes self as string
    func eventFilterEncoded() -> String?
}

/// Event Filterable
/// Combination of EventFilterComparable and EventFilterEncodable protocols
public protocol EventFilterable: EventFilterComparable, EventFilterEncodable {}

extension BigUInt: EventFilterable {}

extension BigInt: EventFilterable {}

extension Data: EventFilterable {}

extension String: EventFilterable {}

extension Address: EventFilterable {}

public struct EventFilter {
    public enum Block {
        case latest
        case pending
        case blockNumber(UInt64)

        var encoded: String {
            switch self {
            case .latest:
                return "latest"
            case .pending:
                return "pending"
            case let .blockNumber(number):
                return String(number, radix: 16).withHex
            }
        }
    }

    public init() {}

    public init(fromBlock: Block?, toBlock: Block?,
                addresses: [Address]? = nil,
                parameterFilters: [[EventFilterable]?]? = nil) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.addresses = addresses
        self.parameterFilters = parameterFilters
    }

    public var fromBlock: Block?
    public var toBlock: Block?
    public var addresses: [Address]?
    public var parameterFilters: [[EventFilterable]?]?

    public func rpcPreEncode() -> EventFilterParameters {
        var encoding = EventFilterParameters()
        if fromBlock != nil {
            encoding.fromBlock = fromBlock!.encoded
        }
        if toBlock != nil {
            encoding.toBlock = toBlock!.encoded
        }
        if addresses != nil {
            if addresses!.count == 1 {
                encoding.address = [self.addresses![0].address]
            } else {
                var encodedAddresses = [String?]()
                for addr in addresses! {
                    encodedAddresses.append(addr.address)
                }
                encoding.address = encodedAddresses
            }
        }
        return encoding
    }
}
