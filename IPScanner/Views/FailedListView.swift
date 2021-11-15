//
//  FailedListView.swift
//  IPScanner
//
//  Created by Timothy Sonner on 11/15/21.
//

import SwiftUI
import Collections
import MapKit

struct FailedListView: View {
    
    let arrayOfScannedIPViewModel: [UriViewModel.ScannedIPViewModel]
    var body: some View {
        
        List {
            ForEach(arrayOfScannedIPViewModel) {
                ip in
                if ip.statusCodeReturned != 200 {
                    NavigationLink(destination:
                                    DataView(scannedIPViewModel: ip)) {
                        HStack {
                            Text("\(ip.ipv4Address)")
                            
                            Text("\(ip.domainNameAddress)")
                            Text("\(ip.statusCodeReturned)")
                                .foregroundColor(.red)
                        }
                    }
                }
                
            }
            
        }
    }
}

struct FailedListView_Previews: PreviewProvider {
    static var previews: some View {
        let dict: OrderedDictionary = ["test1": "One"]
        FailedListView(arrayOfScannedIPViewModel: [UriViewModel.ScannedIPViewModel(id: UUID(), domainNameAddress: "foo.bar.com", ipv4Address: "1.2.3.4", statusCodeReturned: 200, htmlString: "<HTML> </HTML>", httpHeaders: dict, center: CLLocationCoordinate2D(latitude: 25.7617,longitude: 80.1918), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))])
        
    }
}
