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

        guard let message = Message(string: base64QueryString, using: .utf8) else {
            return false
        }

        return message.verify(with: publicKey, signature: signature, digestType: .sha256)
    }
}
