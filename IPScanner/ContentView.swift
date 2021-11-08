//
//  ContentView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewViewModel(webService: WebService())
    @State var lowerRange = ""
    @State var upperRange = ""
    
    var body: some View {
        VStack {
            Text(viewModel.hasError ? "has error" : "no error")
            TextField("Lower IP Range", text: $lowerRange)
            TextField("Upper IP Range", text: $upperRange)
            Button("Scan") {
                viewModel.explodeRangeofIPV4s(lowerBounds: lowerRange, upperBounds: upperRange)
                // fire call to start scanning the array of ips
                Task {
                    await viewModel.scanRangeOfIPV4s(arrayToScan: viewModel.arrayOfIPV4sToScan)
                }
            }
            List {
                ForEach(viewModel.arrayOfScannedIPViewModel) {
                    ip in
                    Text("\(ip.IPV4address) OK")
                }
            }
            
        }
//            Text("Scanning \(viewModel.currentURL)")
//            if viewModel.wasScanSuccessful {
//                Text("Site exists")
//            } else {
//                Text(viewModel.errorDescription)
//            }
//        }
//        .task {
//            await viewModel.fetchAddress(url: viewModel.currentURL)
//        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
