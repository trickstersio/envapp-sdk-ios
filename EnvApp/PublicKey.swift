//
//  File.swift
//  
//
//  Created by Alexandr Gaidukov on 13.02.2020.
//

import Foundation

private extension SecKey {
    static func key(withData keyData: Data, isPublic: Bool) throws ->  SecKey {
        
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let sizeInBits = keyData.count * 8
        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: keyClass,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
            kSecReturnPersistentRef: true
        ]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            throw EnvAppError.keyCreateFailed(error?.takeRetainedValue())
        }
        return key
    }
    
    func isValid(forClass requiredClass: CFString) -> Bool {
        
        let attributes = SecKeyCopyAttributes(self) as? [CFString: Any]
        guard let keyType = attributes?[kSecAttrKeyType] as? String, let keyClass = attributes?[kSecAttrKeyClass] as? String else {
            return false
        }
        
        let isRSA = keyType == (kSecAttrKeyTypeRSA as String)
        let isValidClass = keyClass == (requiredClass as String)
        return isRSA && isValidClass
    }
}

private extension Data {
    func stripKeyHeader() throws -> Data {
        let node: Asn1Parser.Node
        do {
            node = try Asn1Parser.parse(data: self)
        } catch {
            throw EnvAppError.asn1ParsingFailed
        }
        
        guard case .sequence(let nodes) = node else {
            throw EnvAppError.asn1ParsingFailed
        }
        
        let onlyHasIntegers = nodes.filter { node -> Bool in
            if case .integer = node {
                return false
            }
            return true
        }.isEmpty
        
        if onlyHasIntegers {
            return self
        }
        
        if let last = nodes.last, case .bitString(let data) = last {
            return data
        }
        
        if let last = nodes.last, case .octetString(let data) = last {
            return data
        }
        
        throw EnvAppError.asn1ParsingFailed
    }
}

public struct PublicKey {
    
    let reference: SecKey
    
    public init(data: Data) throws {
        let dataWithoutHeader = try data.stripKeyHeader()
        reference = try SecKey.key(withData: dataWithoutHeader, isPublic: true)
    }
    
    public init(reference: SecKey) throws {
        guard reference.isValid(forClass: kSecAttrKeyClassPublic) else {
            throw EnvAppError.wrongPublicKey
        }
        
        self.reference = reference
    }
    
    public init(base64Encoded base64String: String) throws {
        guard let data = Data(base64Encoded: base64String, options: [.ignoreUnknownCharacters]) else {
            throw EnvAppError.invalidBase64String
        }
        try self.init(data: data)
    }
    
    public init(pemEncoded pemString: String) throws {
        let base64String = try PublicKey.base64String(pemEncoded: pemString)
        try self.init(base64Encoded: base64String)
    }
    
    public init(pemNamed pemName: String, in bundle: Bundle) throws {
        guard let path = bundle.path(forResource: pemName, ofType: "pem") else {
            throw EnvAppError.pemFileNotFound(pemName)
        }
        let keyString = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        try self.init(pemEncoded: keyString)
    }
    
    public init(derNamed derName: String, in bundle: Bundle) throws {
        guard let path = bundle.path(forResource: derName, ofType: "der") else {
            throw EnvAppError.derFileNotFound(derName)
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        try self.init(data: data)
    }
    
    private static func base64String(pemEncoded pemString: String) throws -> String {
        let lines = pemString.components(separatedBy: "\n").filter { line in
            return !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }
        
        guard lines.count != 0 else {
            throw EnvAppError.pemDoesNotContainKey
        }
        
        return lines.joined(separator: "")
    }
}
