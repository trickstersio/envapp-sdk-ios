//
//  File.swift
//  
//
//  Created by Alexandr Gaidukov on 13.02.2020.
//

import Foundation

private extension String {
    var base64String: String {
        var base64 = replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
    
    var base64URLString: String {
        return replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
    }
}

public enum EnvAppError: Error {
    case wrongPublicKey
    case asn1ParsingFailed
    case keyCreateFailed(Error?)
    case invalidBase64String
    case pemDoesNotContainKey
    case pemFileNotFound(String)
    case derFileNotFound(String)
}

extension EnvAppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongPublicKey:
            return "Wrong Public Key format"
        case .asn1ParsingFailed:
            return "ASN1 Parsing Failed"
        case .keyCreateFailed(let error):
            return "Key Creation Failed: \(error?.localizedDescription ?? "")"
        case .invalidBase64String:
            return "Invalid Base64 string"
        case .pemDoesNotContainKey:
            return "PEM file does not contain key"
        case .pemFileNotFound(let path):
            return "PEM file not found at \(path)"
        case .derFileNotFound(let path):
            return "DER file not found at \(path)"
        }
    }
}

private extension Data {
    func verify(with key: PublicKey, signature: Signature, digestType: Signature.DigestType) -> Bool {
        let digest = digestType.digest(for: self)
        var digestBytes = [UInt8](repeating: 0, count: digest.count)
        digest.copyBytes(to: &digestBytes, count: digest.count)
        
        var signatureBytes = [UInt8](repeating: 0, count: signature.data.count)
        signature.data.copyBytes(to: &signatureBytes, count: signature.data.count)
        
        let status = SecKeyRawVerify(key.reference, digestType.padding, digestBytes, digestBytes.count, signatureBytes, signatureBytes.count)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
}

public struct EnvAppValidator {
    public static func validateSignatureOf(url: URL, publicKey: PublicKey, signatureKey: String = "signature") -> Bool {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return false
        }

        guard let signatureString = queryItems.first(where: { $0.name == signatureKey})?.value else {
            return false
        }

        let params = queryItems.filter { $0.name != signatureKey }
        
        guard let signature = Signature(base64Encoded: signatureString.base64String) else { return false }

        guard let queryString = params.compactMap({
            guard let value = $0.value else { return nil }
            return "\($0.name)=\(value)"
        }).joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return false }
        
        guard let base64QueryString = (queryString.data(using: .utf8)?.base64EncodedString()).map ({ $0.base64URLString }) else {
            return false
        }

        guard let data = base64QueryString.data(using: .utf8) else {
            return false
        }

        return data.verify(with: publicKey, signature: signature, digestType: .sha256)
    }
}
