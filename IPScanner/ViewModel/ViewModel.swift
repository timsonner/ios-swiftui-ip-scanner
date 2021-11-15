//
//  ViewModel.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation
import OrderedCollections
import MapKit

@MainActor
class UriViewModel: ObservableObject {
    
    @Published var hasError: Bool = false
    @Published var wasScanSuccessful: Bool = false
    @Published var errorDescription = ""
    @Published var currentURL = ""
    @Published var arrayOfAddressesToScan: [String] = []
    @Published var arrayOfResponseSuccess: [ScannedIPViewModel] = []
    @Published var arrayOfAddressesWithoutData: [ScannedIPViewModel] = []
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
        self.arrayOfAddressesToScan = arrayOfIPV4Addresses
    }
    
    func scanAddress(ipv4Address: String) async {
        self.isScanning = true
        do {
            //            let addressToScan = try await webService.networkRequest(url: urlString)
            // this only works if the ip address is converted to a proper url. You can't pass an ip address here or it generates and ssl error. Possibly because the url on the ssl CA is a url and not an ip, thus you get a mismatch and it throws an ssl error.
            
            let reverseDnsLookup = try await webService.reverseDnsLookup(ipv4: ipv4Address)
            
            if reverseDnsLookup.hasAnswer {
                print("scanAddress() -> Results from the reverse DNS lookup: \(String(describing: reverseDnsLookup.answer))")
                
                // add condition here to check if has data is true, if so, add to scanned ip view model, if false, add to ips that didn't have data array. set has data on viewmodel object.
                var reverseDnsLookupAnswer = reverseDnsLookup.answer![0].data
                // removes trailing "." from reverse dns answer
                reverseDnsLookupAnswer.removeLast()
                
                let geoLocation = try await webService.getGeoLocationOfIP(ipv4Address: ipv4Address)
                
                print("scanAddress() -> Attempting to get HTTP Headers and HTML from \(reverseDnsLookupAnswer)")
                let getHttpHeadersAndHtml = try await webService.getHttpHeadersandHtml(url: reverseDnsLookupAnswer, ipv4Address: ipv4Address, center: geoLocation.center, span: geoLocation.span) // add MKCoordinateRecion here
                
                if let scannedAddress = getHttpHeadersAndHtml {
                    self.arrayOfResponseSuccess.append(scannedAddress)
                    print("scanAddress() -> Added address to array")
                }
                
            } else {
                print("scanAddress() -> rDNS record does not exist")
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
        for address in arrayOfAddressesToScan {
            self.currentURL = address
            self.arrayCounter += 1
            await scanAddress(ipv4Address: address)
        }
    }
    
    struct ScannedIPViewModel: Identifiable {
        // i have no idea why, but if you have optionals declared here, it will break a ForEach List
        var id = UUID()
        // var hasData: Bool
        var domainNameAddress: String
        var ipv4Address: String
        var statusCodeReturned: Int
        var htmlString: String
        var httpHeaders: OrderedDictionary<String, String>?
        var center: CLLocationCoordinate2D
        var span: MKCoordinateSpan
    }
    
    struct ReversedDnsIPViewModel: Identifiable {
        var id = UUID()
        var hasAnswer: Bool
        var answer: [Answer]?
    }
}
