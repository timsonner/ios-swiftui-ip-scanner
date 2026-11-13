//
//  DataView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/11/21.
//

import SwiftUI
import Collections
import MapKit

struct DataView: View {
    @State var showWebView = false
    let scannedIPViewModel: UriViewModel.ScannedIPViewModel
    
    var body: some View {
        VStack {
            Text("\(scannedIPViewModel.domainNameAddress)")
                .font(.title2)
            Text("\(scannedIPViewModel.ipv4Address)")
            Text("\(scannedIPViewModel.statusCodeReturned)")
                .foregroundColor(scannedIPViewModel.statusCodeReturned == 200 ? .green : .red)
            
            if let httpHeaders = scannedIPViewModel.httpHeaders {
                HttpHeadersView(httpHeaders: httpHeaders)
            }
            
            Text("HTML")
                .font(.title2)
            if showWebView {
                WebView(url: scannedIPViewModel.htmlString)
            } else {
                VStack {
                    Text(scannedIPViewModel.htmlString)
                    Spacer()
                }
            }
            
            Button {
                showWebView.toggle()
            } label: {
                Text(showWebView ? "Show as Text": "Show as Web Page")
            }
            .buttonStyle(.borderedProminent)
            
            MapView(center: scannedIPViewModel.center, span: scannedIPViewModel.span)
                .frame(minHeight: 200)
        }
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        let dict: OrderedDictionary = ["test1": "One"]
        DataView(scannedIPViewModel: UriViewModel.ScannedIPViewModel(id: UUID(), domainNameAddress: "foo.bar.com", ipv4Address: "1.2.3.4", statusCodeReturned: 200, htmlString: "<html><body><h1>Hello Foo!</h1></body></html>", httpHeaders: dict, center: CLLocationCoordinate2D(latitude: 25.7617, longitude: 80.1918), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
    }
}
