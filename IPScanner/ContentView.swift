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
            TextField("Lower IP Range", text: $lowerRange)
            TextField("Upper IP Range", text: $upperRange)
            Button("Foo!") {
                viewModel.explodeRangeofIPV4s(lowerBounds: lowerRange, upperBounds: upperRange)
            }
            List {
                ForEach(viewModel.arrayOfIPV4s, id: \.self) {
                    ip in
                    Text("\(ip)")
                }
            }
            Text(viewModel.hasError ? "has error" : "no error")
            Text("Scanning \(viewModel.currentURL)")
            if viewModel.wasScanSuccessful {
                Text("Site exists")
            } else {
                Text(viewModel.errorDescription)
            }
        }
        .task {
            await viewModel.fetchAddress(url: viewModel.currentURL)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
