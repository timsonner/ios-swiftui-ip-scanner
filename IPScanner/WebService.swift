//
//  WebService.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import Foundation
// 000.000.000.000
// set each section as lower bounds
// if section1 = 999, section2 += 1, etc, etc

let charaters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
let section1 = ""
var section2 = ""
var section3 = ""
var section4 = ""

struct WebService: Decodable {
    
    enum WebServiceError: Error {
        case genericFailure
        case failedToDecodeData
        case invalidStatusCode
    }
    
    
    
    func networkRequest(url: String) async throws -> Bool? {
 
        let (_, response) = try await URLSession.shared.data(from: URL(string: url)!)
        
        guard let networkRequestResponse = response as? HTTPURLResponse,
              networkRequestResponse.statusCode == 200 else {
//                  throw WebServiceError.invalidStatusCode
                  return false
              }
        print("WebService did its job, success!")
        return true
    }
    
}
