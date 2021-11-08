//
//  WebService.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation

struct WebService: Decodable {
    
    enum WebServiceError: Error {
        case genericFailure
        case failedToDecodeData
        case invalidStatusCode
    }
    
    
    
    func networkRequest(url: String) async throws -> ContentViewViewModel.ScannedIPViewModel? {
 
        let (_, response) = try await URLSession.shared.data(from: URL(string: url)!)
        
        guard let networkRequestResponse = response as? HTTPURLResponse,
              networkRequestResponse.statusCode == 200 else {
//                  throw WebServiceError.invalidStatusCode
                  return ContentViewViewModel.ScannedIPViewModel(id: UUID(), IPV4address: url, wasSuccessful: false)
              }
        print("WebService did its job, success!")
        return ContentViewViewModel.ScannedIPViewModel(id: UUID(), IPV4address: url, wasSuccessful: true)
    }
    
}
