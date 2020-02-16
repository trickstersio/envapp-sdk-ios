import XCTest
@testable import EnvApp

final class EnvAppTests: XCTestCase {
    
    let publicKeyString = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtUhyP/6nboQm6VFCUDaH
1ZgENsfkNwaB96LteBzZHCcQLWQMb3/JqALWda2gjk47rCCdxyCuPv4w4colAng6
jxjmkMwipGV9YipmRFhroHFog8a/5j79wS/dTG24Qlr+qfwmZXaxJ7NfbKWk+exo
oK6OXDzKP1QJENwvHIdUaZeLHF/US4VdAxt2gfnnk+CB3fYyngfTxhY3PGKN/K/r
qV+BDdu7hrMfmV8gDeNuraTFc+rnbtohOPVFniU60jQJding9Y5FWlPWck4aBrQX
HHwJCqXBQSw1ZEfWGQXWcsX3cmgl9KpbFgncGGl4X9QGW6fQaFJUwhJeDv1Duh4K
NwIDAQAB
-----END PUBLIC KEY-----
"""
    
    func testCorrectSignature() {
        guard let publicKey = try? PublicKey(pemEncoded: publicKeyString) else {
            XCTFail()
            return
        }
        
        let url = URL(string: "gettaxi://launch?BASE_URL=test://launch&DEBUG=1&LOGIN=test@example.com&PASSWORD=qwerty123&signature=bdjv7jxtIRDrSHpPdvUOLJIowIG7TF1vwtJDi8uwKZPwp1vV-jbEzxioTy5RpDMlDQORLz-SeYEPhqpVmxS5al4reR7EMZJyE_205fpM19Q-56oINJy8MUMvsbJSUMvfcKxjEpX37xb8KUVTb2FP2m0OVkfwgyd-bS-69K7zOjhVSKwUy8ipyfBmaphASzfqCAEwvx_fVz9ukh2TNcoXrBti1hoHPx5LjIfZm9_HJNvKomCFOzVfSo8XvfLReIoDVrroTQ4fnUl2SSFzbbgZKfXTh_BOEOfSNsY32lOXd5hc1-QtiKV_oyrJlRTGrjgv74WgxeZ8CZSkqeH3r6UNXw==")!
        
        XCTAssertTrue(EnvAppValidator.validateSignatureOf(url: url, publicKey: publicKey))
    }
    
    func testIncorrectSignature() {
        guard let publicKey = try? PublicKey(pemEncoded: publicKeyString) else {
            XCTFail()
            return
        }
        
        let url = URL(string: "gettaxi://launch?BASE_URL=test://launch&DEBUG=1&LOGIN=test@example.com&PASSWORD=qwerty123&signature=asjv7jxtIRDrSHpPdvUOLJIowIG7TF1vwtJDi8uwKZPwp1vV-jbEzxioTy5RpDMlDQORLz-SeYEPhqpVmxS5al4reR7EMZJyE_205fpM19Q-56oINJy8MUMvsbJSUMvfcKxjEpX37xb8KUVTb2FP2m0OVkfwgyd-bS-69K7zOjhVSKwUy8ipyfBmaphASzfqCAEwvx_fVz9ukh2TNcoXrBti1hoHPx5LjIfZm9_HJNvKomCFOzVfSo8XvfLReIoDVrroTQ4fnUl2SSFzbbgZKfXTh_BOEOfSNsY32lOXd5hc1-QtiKV_oyrJlRTGrjgv74WgxeZ8CZSkqeH3r6UNXw==")!
        
        XCTAssertFalse(EnvAppValidator.validateSignatureOf(url: url, publicKey: publicKey))
    }

    static var allTests = [
        ("testCorrectSignature", testCorrectSignature),
        ("testIncorrectSignature", testIncorrectSignature)
    ]
}
