//
//  WebService.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation
import Collections
import MapKit

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
    func getGeoLocationOfIP(ipv4Address: String) async throws -> MKCoordinateRegion {
        print("getGeoLocationOfIP -> fetching geo location of server")
        let url = URL(string: "http://ip-api.com/json/\(ipv4Address)")!
        let request = URLRequest(url: url)
        guard let (data, response) = try? await URLSession.shared.data(for: request) else {
            print("getGeoLocationOfIP -> Couldn't open a URLSession")
            throw WebServiceError.genericFailure
            
        }
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("getGeoLocationOfIP -> Response was invalid")
            throw WebServiceError.invalidStatusCode
        }
        guard let decodedData = try? JSONDecoder().decode(GeoLocation.self, from: data) else {
            print("getGeoLocationOfIP -> Unable to decode the data")
            throw WebServiceError.failedToDecodeData
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: decodedData.lat, longitude: decodedData.lon), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    func reverseDnsLookup(ipv4: String) async throws -> UriViewModel.ReversedDnsIPViewModel {
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
        print("=================================================================================")
        print("reverseDnsLookup() -> Reversed IP is \(reversedIpv4)")
        
        let googleReversedDnsUrl = URL(string: "https://dns.google/resolve?name=\(reversedIpv4).in-addr.arpa&type=PTR")!
        print("reverseDnsLookup() -> Requesting reverse DNS lookup from: \(googleReversedDnsUrl)")
        
        let (data, response) = try await URLSession.shared.data(from: googleReversedDnsUrl)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("reverseDnsLookup() -> Invalid status code")
            throw WebServiceError.invalidStatusCode
        }
        
        guard let decodedData = try? JSONDecoder().decode(GoogleDnsResponseModel.self, from: data)
        else {
            print("reverseDnsLookup() -> Failed to decode data")
            //            throw WebServiceError.failedToDecodeData
            return UriViewModel.ReversedDnsIPViewModel(id: UUID(), hasAnswer: false)
        }
        print("reverseDnsLookup() -> Successfully decoded data")
        return UriViewModel.ReversedDnsIPViewModel(id: UUID(), hasAnswer: true, answer: decodedData.answer)
    }
    
    func getHttpHeadersandHtml(url: String, ipv4Address: String, center: CLLocationCoordinate2D, span: MKCoordinateSpan) async throws -> UriViewModel.ScannedIPViewModel? {
        print("getHttpHeadersandHtml() -> Initializing...")
        var htmlString = ""
        
        let falseHeaders: OrderedDictionary = ["HTTP Headers": "False"]

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
      
        let session = URLSession(configuration: configuration, delegate: TrustAllSslCertificatesSessionDelegate(), delegateQueue: nil)
        
        var request = URLRequest(url: URL(string: "https://\(url)")!)
        request.httpMethod = "HEAD"
        
       // MARK: Retrieve response
        guard let (_, response) = try? await session.data(for: request) else {
            return UriViewModel.ScannedIPViewModel(id: UUID(), domainNameAddress: "\(url)", ipv4Address: ipv4Address, statusCodeReturned: 408, htmlString: "", httpHeaders: falseHeaders, center: center, span: span)
        }
        
        print("getHttpHeadersandHtml() -> Retrieving response...")
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            
            print("getHttpHeadersandHtml() -> Failed to retrieve response")
            let httpResponse = response as? HTTPURLResponse
            
            return UriViewModel.ScannedIPViewModel(id: UUID(), domainNameAddress: url, ipv4Address: ipv4Address, statusCodeReturned: httpResponse!.statusCode, htmlString: "", httpHeaders: falseHeaders, center: center, span: span)
        }
        // MARK: Retrieve data
        guard let (data, _) = try? await session.data(from: (URL(string: "https://\(url)"))!) else {
            
            print("getHttpHeadersandHtml() -> Failed to retrieve data")
            return UriViewModel.ScannedIPViewModel(id: UUID(), domainNameAddress: url, ipv4Address: ipv4Address, statusCodeReturned: httpResponse.statusCode, htmlString: "", httpHeaders: falseHeaders, center: center, span: span)
        }
        // MARK: Convert headers to ordered dictionary
        let httpHeaders = httpResponse.allHeaderFields as? [String: String]
        let dictionaryOfHeaders = OrderedDictionary(uniqueKeys: httpHeaders!.keys, values: httpHeaders!.values)
        
        if let mimeType = httpResponse.mimeType, mimeType == "text/html"
        {
            htmlString = String(data: data, encoding: .utf8)!
        }
        
        print("getHttpHeadersandHtml() -> Finished with success!")
        //        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
        //                   let string = String(data: data, encoding: .utf8) {
        //                   print(string) // prints html of page to console
        //               }
        
        //        return ContentViewViewModel.ScannedIPViewModel(id: UUID(), IPV4address: url, statusCodeReturned: httpResponse.statusCode, data: httpResponse.mimeType == "text/html" ? String(data: data, encoding: .utf8) : "No Data to display")
        return UriViewModel.ScannedIPViewModel(id: UUID(), domainNameAddress: url, ipv4Address: ipv4Address, statusCodeReturned: httpResponse.statusCode, htmlString: htmlString, httpHeaders: dictionaryOfHeaders, center: center, span: span)
        
    }
    
}
