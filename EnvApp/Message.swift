//
//  File.swift
//  
//
//  Created by Alexandr Gaidukov on 13.02.2020.
//

import Foundation

struct Message {

    private let data: Data

    init(data: Data) {
        self.data = data
    }

    init?(string: String, using encoding: String.Encoding) {
        guard let data = string.data(using: encoding) else {
            return nil
        }
        self.init(data: data)
    }
    
    func verify(with key: PublicKey, signature: Signature, digestType: Signature.DigestType) -> Bool {
        let digest = digestType.digest(for: data)
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
