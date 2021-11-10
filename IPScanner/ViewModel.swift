//
//  ViewModel.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation

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
    func convertIPV4ToInteger(IPV4Address: String) -> Int {
        let octets: [Int] = IPV4Address.split(separator: ".").map({Int($0)!})
        var numValue: Int = 0
        for i in stride(from:3, through:0, by:-1) {
            // if ipv4 address does not contain 4 sections, you end up here with "Fatal error: Index out of range"
            numValue += octets[3-i] << (i * 8)
        }
        return numValue
    }
    func convertIntegerToIPV4(int: Int) -> String {
        // int >> 24 performs a bitwise shift 24 places to the right
        // & 0xFF is a bitwise AND, and 0xFF in hex is 255 in decimal
        let section1 = String((int >> 24) & 0xFF)
        let section2 = String((int >> 16) & 0xFF)
        let section3 = String((int >> 8) & 0xFF)
        let section4 = String((int >> 0) & 0xFF)
        return "https://" + section1 + "." + section2 + "." + section3 + "." + section4
    }
    
    func explodeRangeofIPV4s(lowerBounds: String, upperBounds: String) {
        var arrayOfIPV4s: [String] = []
        for ip in stride(from:convertIPV4ToInteger(IPV4Address: lowerBounds), through: convertIPV4ToInteger(IPV4Address: upperBounds), by: 1) {
            arrayOfIPV4s.append(convertIntegerToIPV4(int: ip))
        }
        self.arrayOfIPV4sToScan = arrayOfIPV4s
    }
    
    func scanAddress(url: String) async {
        self.isScanning = true
        do {
            let addressToScan = try await webService.networkRequest(url: url)
            if let scannedAddress = addressToScan {
                self.arrayOfScannedIPViewModel.append(scannedAddress)
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
            await scanAddress(url: address)
        }
        
    }
    
    struct ScannedIPViewModel: Identifiable {
        
        var id = UUID()
        var IPV4address: String
        var statusCodeReturned: Int
        var data: String?
    }
    
    
}
