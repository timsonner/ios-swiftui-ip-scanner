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
    // also, implent geolocation at some point using an ip.
    //
    //Geolocation API - Documentation - JSON https://ip-api.com › docs › api:json
    
    func reverseDnsLookup(ipv4: String) async throws -> ContentViewViewModel.ReversedDnsIPViewModel {
        // performs reverse dns lookup
        // example query: https://dns.google/resolve?name=4.3.2.1.in-addr.arpa&type=PTR
        let components = ipv4.components(separatedBy: ".").reversed()
        // seperate the ipv4 string into chunks, then reverse the order of the chunks
        var reversedIpv4 = ""
        for i in components {
            reversedIpv4 += i + "."
        } // add all the chunks back together again
        reversedIpv4.removeLast()
        // trim the last period off, you could leave this, but would need to modify the googleReversedDnsUrl
        print("Reversed IP is \(reversedIpv4)")
        
        let googleReversedDnsUrl = URL(string: "https://dns.google/resolve?name=\(reversedIpv4).in-addr.arpa&type=PTR")!
        
        print("Requesting rDNS lookup from: \(googleReversedDnsUrl)")
        
        let (data, response) = try await URLSession.shared.data(from: googleReversedDnsUrl)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Invalid status code")
            throw WebServiceError.invalidStatusCode
        }
        
        guard let decodedData = try? JSONDecoder().decode(GoogleDnsResponseModel.self, from: data)
        else {
            print("Failed to decode data")
            //            throw WebServiceError.failedToDecodeData
            return ContentViewViewModel.ReversedDnsIPViewModel(id: UUID(), answer: [Answer(data: "nil")])
        }
        print("Successfully decoded data")
        return ContentViewViewModel.ReversedDnsIPViewModel(id: UUID(), answer: decodedData.answer)
    }
    
    func getHttpHeadersandHtml(url: String) async throws -> ContentViewViewModel.ScannedIPViewModel? {
        var htmlString = ""
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        
        //        let session = URLSession(configuration: configuration, delegate: FooBar(url: url), delegateQueue: nil)
        let session = URLSession(configuration: configuration, delegate: TrustAllSslCertificatesSessionDelegate(), delegateQueue: nil)
        
        var request = URLRequest(url: URL(string: "https://\(url)")!)
        request.httpMethod = "HEAD"
        
        // gets the html from the site
        guard let (data, _) = try? await session.data(from: (URL(string: "https://\(url)"))!) else {
            print("Couldn't retrieve any website data")
            throw WebServiceError.genericFailure
        }
       
        
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
