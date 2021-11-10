//
//  ContentView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/5/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewViewModel(webService: WebService())
    @State var lowerBounds = ""
    @State var upperBounds = ""
    
    var body: some View {
        NavigationView {
            VStack {
                //            Text(viewModel.hasError ? "has error" : "no error")
                TextField("Lower IP Range", text: $lowerBounds)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Upper IP Range", text: $upperBounds)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Scan") {
                    viewModel.explodeRangeofIPV4s(lowerBounds: lowerBounds, upperBounds: upperBounds)
                    // fire call to start scanning the array of ips
                    Task {
                        await viewModel.scanRangeOfIPV4s(arrayToScan: viewModel.arrayOfIPV4sToScan)
                    }
                }
                .buttonStyle(.borderedProminent)
                if viewModel.isScanning {
                    HStack {
                        
                        Text("Scanning: \(viewModel.arrayCounter) of \(viewModel.arrayOfIPV4sToScan.count) Addresses")
                        Text("\(viewModel.currentURL)")
                        
                        Spacer()
                        ProgressView()
                    }
                }
                //            Text(viewModel.errorDescription)
                List {
                    if !viewModel.arrayOfScannedIPViewModel.isEmpty {
                        HStack {
                            Spacer()
                            Text("Results:")
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                    
                    ForEach(viewModel.arrayOfScannedIPViewModel) {
                        ip in
                        NavigationLink(destination:
                                        Text("\(ip.data!)")) {
                            HStack {
                                Text("\(ip.IPV4address)")
                                Text("\(ip.statusCodeReturned)")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            } // MARK: end of VStack
            .padding()
            .navigationTitle("IP Scanner")
        } // MARK: end of NavigationView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
