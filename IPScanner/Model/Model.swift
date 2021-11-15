//
//  Model.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/14/21.
//

// This file was generated from JSON Schema using codebeautify, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation

// MARK: - GoogleDnsResponseModel

struct GoogleDnsResponseModel: Decodable {

//    let status: Int
//    let tc, rd, ra, ad: Bool
//    let cd: Bool
//    let question: [Question]
    let answer: [Answer]

    enum CodingKeys: String, CodingKey {
//        case status = "Status"
//        case tc = "TC"
//        case rd = "RD"
//        case ra = "RA"
//        case ad = "AD"
//        case cd = "CD"
//        case question = "Question"
        case answer = "Answer"
    }
}

// MARK: - Answer
struct Answer: Decodable {
//    let name: String
//    let type, ttl: Int
    let data: String

    enum CodingKeys: String, CodingKey {
//        case name, type
//        case ttl = "TTL"
        case data
    }
}

// MARK: - Question
//struct Question: Decodable {
//    let name: String
//    let type: Int
//}

struct GeoLocation: Decodable {
    let query, status, country, countryCode: String
    let region, regionName, city, zip: String
    let lat, lon: Double
    let timezone, isp, org, purpleAs: String

    enum CodingKeys: String, CodingKey {
        case query, status, country, countryCode, region, regionName, city, zip, lat, lon, timezone, isp, org
        case purpleAs = "as"
    }
}


