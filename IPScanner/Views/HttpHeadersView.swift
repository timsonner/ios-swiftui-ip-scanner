//
//  HttpHeaders.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/14/21.
//

import SwiftUI
import Collections

struct HttpHeadersView: View {
    let httpHeaders: OrderedDictionary<String, String>
    
    var body: some View {
        ScrollView {
        VStack {
            Text("HTTP Headers")
                .font(.title2)
            ForEach(0..<httpHeaders.keys.count) {
                i in
                Text("\(httpHeaders.keys[i])")
                    .fontWeight(.bold)
                Text("\(httpHeaders.values[i])")
            }
        }
        }
    }
}

struct HttpHeaders_Previews: PreviewProvider {
    static var previews: some View {
        let dict: OrderedDictionary = ["test1": "One"]
        HttpHeadersView(httpHeaders: dict)
    }
}
