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

// Sample query: https://dns.google/resolve?name=8.8.8.8.in-addr.arpa&type=PTR
// Note name is reversed and appended with ".in-addr.arpa"
// Sample response: {"Status":0,"TC":false,"RD":true,"RA":true,"AD":false,"CD":false,"Question":[{"name":"8.8.8.8.in-addr.arpa.","type":12}],"Answer":[{"name":"8.8.8.8.in-addr.arpa.","type":12,"TTL":18532,"data":"dns.google."}]}
// Note the trailing "." on the data object "dns.google."
// "data" can be absent, so if GoogleDnsResponseModel.Answer[0].data != nil, proceed. just check data for nil.

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


