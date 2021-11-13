//
//  BrowserView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/11/21.
//

import SwiftUI
import WebKit
import Collections

struct DataView: View {
    @State var showWebView = false
    let httpHeaders: OrderedDictionary<String, String>
     let htmlString: String
    
    var body: some View {
        VStack {
                    Text("HTTP Headers")
                        .font(.title2)
            ForEach(0..<httpHeaders.keys.count) {
                i in
                Text("\(httpHeaders.keys[i])")
                    .fontWeight(.bold)
                Text("\(httpHeaders.values[i])")
            }
            
                    Text("HTML")
                        .font(.title2)
                        if showWebView {
                            WebView(url: htmlString)
            //            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 500, maxHeight: .infinity, alignment: .center)
                        } else {
                            VStack {
                                Text(htmlString)
                                Spacer()
                            }
                        }
                        
                            Button {
                                showWebView.toggle()
                            } label: {
                                Text(showWebView ? "Show as Text": "Show as Web Page")
                        }
                            .buttonStyle(.borderedProminent)
                    }
        }
    }



struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        //        DataView(data: "<html><body><h1>Hello Foo!</h1></body></html>")
        let dict: OrderedDictionary = ["test1": "One"]
        DataView(httpHeaders: dict, htmlString: "<html><body><h1>Hello Foo!</h1></body></html>")
    }
}
