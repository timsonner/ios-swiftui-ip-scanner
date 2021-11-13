//
//  WebService.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation
import Collections

struct WebService: Decodable {
    
    enum WebServiceError: Error {
        case genericFailure
        case failedToDecodeData
        case invalidStatusCode
        case invalidAddress
    }
    
    
    func networkRequest(url: String) async throws -> ContentViewViewModel.ScannedIPViewModel? {
        var htmlString = ""
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        
        let session = URLSession(configuration: configuration)
        
        var request = URLRequest(url: URL(string: "https://\(url)")!)
        request.httpMethod = "HEAD"
        
        let (data, _) = try await session.data(from: (URL(string: "https://\(url)"))!)
        // gets the html from the site
        
        let (_, response) = try await session.data(for: request)
        // gets the http headers
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw WebServiceError.invalidStatusCode
        }
        
        let httpHeaders = httpResponse.allHeaderFields as? [String: String]
        let dictionaryOfHeaders = OrderedDictionary(uniqueKeys: httpHeaders!.keys, values: httpHeaders!.values)
        
        if let mimeType = httpResponse.mimeType, mimeType == "text/html"
           {
            htmlString = String(data: data, encoding: .utf8)!
        }
        
        print("WebService did its job, success!")
        //        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
        //                   let string = String(data: data, encoding: .utf8) {
        //                   print(string) // prints html of page to console
        //               }
        
        //        return ContentViewViewModel.ScannedIPViewModel(id: UUID(), IPV4address: url, statusCodeReturned: httpResponse.statusCode, data: httpResponse.mimeType == "text/html" ? String(data: data, encoding: .utf8) : "No Data to display")
        return ContentViewViewModel.ScannedIPViewModel(id: UUID(), IPV4address: url, statusCodeReturned: httpResponse.statusCode, htmlString: htmlString, httpHeaders: dictionaryOfHeaders)
        
    }
    
}
