//
//  TrustAllSslCertificatesSessionDelegate.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/13/21.
//

import Foundation

class TrustAllSslCertificatesSessionDelegate: NSObject, URLSessionDelegate {
    // Trust all SSL certificates
    // Not secure, but not really trying to be here. Maybe this actually is production code, its doing what I want it to do, ATS was in my way and we aren't passing sensitive data of any kind around.
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
       
       let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        print("Inside OverRideSslCertification, challenge = \(challenge.protectionSpace.host)")
       completionHandler(.useCredential, urlCredential)
    }
}
