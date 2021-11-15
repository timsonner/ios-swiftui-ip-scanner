//
//  ScanView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/14/21.
//

import SwiftUI

struct ScanView: View {
    let viewModel: UriViewModel
    
    @State var lowerBounds = ""
    @State var upperBounds = ""
    
    var body: some View {
        VStack {
        TextField("Lower IP Range", text: $lowerBounds)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        TextField("Upper IP Range", text: $upperBounds)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        Button("Scan") {
            viewModel.explodeRangeofIPV4s(lowerBounds: lowerBounds, upperBounds: upperBounds)
            // fire call to start scanning the array of ips
            Task {
                await viewModel.scanRangeOfIPV4s(arrayToScan: viewModel.arrayOfAddressesToScan)
            }
            
        }
        .buttonStyle(.borderedProminent)
    }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(viewModel: UriViewModel(webService: WebService()))
    }
}
