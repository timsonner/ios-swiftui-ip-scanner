//
//  ContentView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/14/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var viewModel = UriViewModel(webService: WebService())
    
    var body: some View {
        NavigationView {
            VStack {
                ScanView(viewModel: viewModel)
                if viewModel.isScanning {
                    HStack {
                        
                        Text("Scanning: \(viewModel.arrayCounter) of \(viewModel.arrayOfAddressesToScan.count) Addresses")
                        Text("\(viewModel.currentURL)")
                        
                        Spacer()
                        ProgressView()
                    }
                }
            TabView() {
//                if !viewModel.arrayOfAddressesWithWebServers.isEmpty {
//                    HStack {
//                        Spacer()
//                        Text("Results:")
//                            .font(.subheadline)
////                        Spacer()
//                    }
//                }
                SuccessListView(arrayOfScannedIPViewModel: viewModel.arrayOfResponseSuccess)
                .tabItem {
                    Label("Success", systemImage: "circle.fill")
                        .foregroundColor(.green)
                }
                FailedListView(arrayOfScannedIPViewModel: viewModel.arrayOfResponseSuccess)

                .tabItem {
                    Label("Failed", systemImage: "circle.fill")
                }
            }
        }
        .padding()
        .navigationTitle("IP Scanner")
    } // MARK: end of NavigationView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
