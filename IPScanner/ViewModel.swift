//
//  ViewModel.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation

@MainActor
class ContentViewViewModel: ObservableObject {
    
//    enum State {
//        case initialState
//        case loading
//        case successScanningIP(data: Bool)
//        case failed(error: Error)
//    }
    
//    @Published private(set) var state: State = .initialState
    // set means changes to this var can only be made from within scope of this class. views can't directly change this var, only reflect its change
    @Published var hasError: Bool = false
    @Published var wasScanSuccessful: Bool = false
    @Published var errorDescription = ""
    @Published var currentURL = "https://8.8.8.8"
    @Published var arrayOfIPV4sToScan: [String] = []
    @Published var arrayOfScannedIPViewModel: [ScannedIPViewModel] = []
    
    
    private let webService: WebService  // dependency injection
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    func convertIPV4ToInteger(IPV4Address: String) -> Int {
        let octets: [Int] = IPV4Address.split(separator: ".").map({Int($0)!})
        var numValue: Int = 0
        for i in stride(from:3, through:0, by:-1) {
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
return section1 + "." + section2 + "." + section3 + "." + section4
    }
    
    func explodeRangeofIPV4s(lowerBounds: String, upperBounds: String) {
        var arrayOfIPV4s: [String] = []
        for ip in stride(from:convertIPV4ToInteger(IPV4Address: lowerBounds), through: convertIPV4ToInteger(IPV4Address: upperBounds), by: 1) {
            arrayOfIPV4s.append(convertIntegerToIPV4(int: ip))
        }
        self.arrayOfIPV4sToScan = arrayOfIPV4s
    }
    
    func fetchAddress(url: String) async {
        do {
            let addressToScan = try await webService.networkRequest(url: url)
            if let scannedAddress = addressToScan {
//                self.wasScanSuccessful = scannedAddress
                self.arrayOfScannedIPViewModel.append(scannedAddress)
            }
        } catch {
            self.errorDescription = returnError(error: error)
            self.hasError = true
        }
    }
    
    func returnError(error: Error) -> String {
        return error.localizedDescription
    }
    
    func scanRangeOfIPV4s(arrayToScan: [String]) async {
        for i in arrayOfIPV4sToScan {
            await fetchAddress(url: i)
        }
    }
    
    struct ScannedIPViewModel: Identifiable {
        
        var id = UUID()
        var IPV4address: String
//        var statusCodeReturned: Int
        var wasSuccessful: Bool
    }
    
    
}
