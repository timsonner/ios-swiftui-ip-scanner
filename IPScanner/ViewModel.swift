//
//  ViewModel.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation
import OrderedCollections

@MainActor
class ContentViewViewModel: ObservableObject {
    
    @Published var hasError: Bool = false
    @Published var wasScanSuccessful: Bool = false
    @Published var errorDescription = ""
    @Published var currentURL = ""
    @Published var arrayOfIPV4sToScan: [String] = []
    @Published var arrayOfScannedIPViewModel: [ScannedIPViewModel] = []
    @Published var isScanning = false
    @Published var arrayCounter = 0
    
    
    private let webService: WebService
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    // add a string extension here that removes whitespaces from parameter before it is passed, or in explode ipv4 function, just sanitize strings before they get here otherwise, "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
    func convertIPV4ToInteger(stringOfIPV4Address: String) -> Int {
        let arrayOfIntegers: [Int] = stringOfIPV4Address.split(separator: ".").map({Int($0)!})
        var integer: Int = 0
        for i in stride(from:3, through:0, by:-1) {
            // if ipv4 address does not contain 4 sections, you end up here with "Fatal error: Index out of range"
            integer += arrayOfIntegers[3-i] << (i * 8)
        }
        return integer
    }
    func convertIntegerToIPV4(integer: Int) -> String {
        // int >> 24 performs a bitwise shift 24 places to the right
        // & 0xFF is a bitwise AND, and 0xFF in hex is 255 in decimal
        let section1 = String((integer >> 24) & 0xFF)
        let section2 = String((integer >> 16) & 0xFF)
        let section3 = String((integer >> 8) & 0xFF)
        let section4 = String((integer >> 0) & 0xFF)
        return section1 + "." + section2 + "." + section3 + "." + section4
    }
    
    func explodeRangeofIPV4s(lowerBounds: String, upperBounds: String) {
        var arrayOfIPV4Addresses: [String] = []
        for ip in stride(from:convertIPV4ToInteger(stringOfIPV4Address: lowerBounds), through: convertIPV4ToInteger(stringOfIPV4Address: upperBounds), by: 1) {
            arrayOfIPV4Addresses.append(convertIntegerToIPV4(integer: ip))
        }
        self.arrayOfIPV4sToScan = arrayOfIPV4Addresses
    }
    
    func scanAddress(urlString: String) async {
        self.isScanning = true
        do {
//            let addressToScan = try await webService.networkRequest(url: urlString)
            // this only works if the ip address is converted to a proper url. You can't pass an ip address here or it generates and ssl error. Possibly because the url on the ssl CA is a url and not an ip, thus you get a mismatch and it throws an ssl error.
            let reverseDnsUrlString = try await webService.reverseDnsLookup(ipv4: urlString)
            print("Inside scanAddress function, results from the DNSreverse: \(reverseDnsUrlString)")
            if reverseDnsUrlString.answer[0].data != "nil" {
            var trimmedString = reverseDnsUrlString.answer[0].data
            trimmedString.removeLast()
            print("About to scan \(trimmedString)")
            let addressToScan = try await webService.getHttpHeadersandHtml(url: trimmedString)
            if let scannedAddress = addressToScan {
                self.arrayOfScannedIPViewModel.append(scannedAddress)
            }
            } else {
                print("Data returned from reverse dns was nil")
            }
        } catch {
            self.errorDescription = returnError(error: error)
            self.hasError = true
        }
        self.isScanning = false
    }
    
    func returnError(error: Error) -> String {
        return error.localizedDescription
    }
    
    func scanRangeOfIPV4s(arrayToScan: [String]) async {
        for address in arrayOfIPV4sToScan {
            self.currentURL = address
            self.arrayCounter += 1
            await scanAddress(urlString: address)
        }
    }
    
    struct ScannedIPViewModel: Identifiable {
        
        var id = UUID()
        var IPV4address: String
        var statusCodeReturned: Int
        var htmlString: String?
        var httpHeaders: OrderedDictionary<String, String>
    }
    
    struct ReversedDnsIPViewModel: Identifiable {
        var id = UUID()
        var answer: [Answer]
    }
}
