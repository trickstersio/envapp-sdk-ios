//
//  File.swift
//  
//
//  Created by Alexandr Gaidukov on 13.02.2020.
//

import Foundation
import CommonCrypto

struct Signature {
    
    enum DigestType {
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512
    }
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init?(base64Encoded base64String: String) {
        guard let data = Data(base64Encoded: base64String) else {
            return nil
        }
        self.init(data: data)
    }
}

private extension Data {
    func SHA1() -> Data {
        withUnsafeBytes { bytes in
            var digests = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1(bytes.baseAddress, CC_LONG(count), &digests)
            return Data(bytes: digests, count: digests.count)
        }
    }
    
    func SHA224() -> Data {
        withUnsafeBytes { bytes in
            var digests = [UInt8](repeating: 0, count:Int(CC_SHA224_DIGEST_LENGTH))
            CC_SHA224(bytes.baseAddress, CC_LONG(count), &digests)
            return Data(bytes: digests, count: digests.count)
        }
    }
    
    func SHA256() -> Data {
        withUnsafeBytes { bytes in
            var digests = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes.baseAddress, CC_LONG(count), &digests)
            return Data(bytes: digests, count: digests.count)
        }
    }
    
    func SHA384() -> Data {
        withUnsafeBytes { bytes in
            var digests = [UInt8](repeating: 0, count:Int(CC_SHA384_DIGEST_LENGTH))
            CC_SHA384(bytes.baseAddress, CC_LONG(count), &digests)
            return Data(bytes: digests, count: digests.count)
        }
    }
    
    func SHA512() -> Data {
        withUnsafeBytes { bytes in
            var digests = [UInt8](repeating: 0, count:Int(CC_SHA512_DIGEST_LENGTH))
            CC_SHA512(bytes.baseAddress, CC_LONG(count), &digests)
            return Data(bytes: digests, count: digests.count)
        }
    }
}

extension Signature.DigestType {
    
    var padding: SecPadding {
        switch self {
        case .sha1: return .PKCS1SHA1
        case .sha224: return .PKCS1SHA224
        case .sha256: return .PKCS1SHA256
        case .sha384: return .PKCS1SHA384
        case .sha512: return .PKCS1SHA512
        }
    }
    
    func digest(for data: Data) -> Data {
        switch self {
        case .sha1: return data.SHA1()
        case .sha224: return data.SHA224()
        case .sha256: return data.SHA256()
        case .sha384: return data.SHA384()
        case .sha512: return data.SHA512()
        }
    }
}
