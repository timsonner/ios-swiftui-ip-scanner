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
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 2
        
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(from: URL(string: url)!)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw WebServiceError.invalidStatusCode
        }
        
        print("WebService did its job, success!")
        //        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
        //                   let string = String(data: data, encoding: .utf8) {
        //                   print(string) // prints html of page to console
        //               }
        
        return ContentViewViewModel.ScannedIPViewModel(id: UUID(), IPV4address: url, statusCodeReturned: httpResponse.statusCode, data: httpResponse.mimeType == "text/html" ? String(data: data, encoding: .utf8) : "negativo on the datorino")
    }
    
}
