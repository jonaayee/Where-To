//
//  ContentView.swift
//  Where To?
//
//  Created by Jonathan Amburgy on 2/17/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var routingVM = RoutingViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var validResultsA: [(MKMapItem, CLLocationCoordinate2D)] {
        searchVM.searchResultsA.map { item in (item, item.placemark.coordinate) }
    }
    var validResultsB: [(MKMapItem, CLLocationCoordinate2D)] {
        searchVM.searchResultsB.map { item in (item, item.placemark.coordinate) }
    }
    var validResultsC: [(MKMapItem, CLLocationCoordinate2D)] {
        searchVM.searchResultsC.map { item in (item, item.placemark.coordinate) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search A...", text: $searchVM.queryA)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Search B...", text: $searchVM.queryB)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Search C...", text: $searchVM.queryC)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
                
                if let userLocation = locationManager.userLocation {
                    Map(initialPosition: cameraPosition) {
                        
                        RouteOverlayContent(route: routingVM.route)
                        
                        Marker("You", systemImage: "location.circle.fill", coordinate: userLocation)
                            .tint(.blue)
                        
                        SearchResultsContent(
                            results: validResultsA,
                            userLocation: userLocation,
                            routingVM: routingVM,
                            markerColor: .red,
                            labelSuffix: "(A)"
                        )
                        
                        SearchResultsContent(
                            results: validResultsB,
                            userLocation: userLocation,
                            routingVM: routingVM,
                            markerColor: .green,
                            labelSuffix: "(B)"
                        )
                        
                        SearchResultsContent(
                            results: validResultsC,
                            userLocation: userLocation,
                            routingVM: routingVM,
                            markerColor: .purple,
                            labelSuffix: "(C)"
                        )
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: userLocation,
                                latitudinalMeters: 5000,
                                longitudinalMeters: 5000
                            )
                        )
                    }
                } else {
                    
                }
            }
            .navigationTitle("Where To?")
        }
    }
}

#Preview {
    ContentView()
}

struct RouteOverlayContent: MapContent {
    let route: MKRoute?
    
    var body: some MapContent {
        if let route {
            MapPolyline(route.polyline)
                .stroke(.blue, lineWidth: 5)
        }
    }
}

struct MapResult: Identifiable {
    let id: String
    let mapItem: MKMapItem
    let coordinate: CLLocationCoordinate2D
    
    init(mapItem: MKMapItem, coordinate: CLLocationCoordinate2D) {
        self.mapItem = mapItem
        self.coordinate = coordinate
        self.id = "\(coordinate.latitude)-\(coordinate.longitude)"
    }
}

struct SearchResultsContent: MapContent {
    let results: [(MKMapItem, CLLocationCoordinate2D)]
    let userLocation: CLLocationCoordinate2D
    let routingVM: RoutingViewModel
    let markerColor: Color
    let labelSuffix: String

    var mappedResults: [MapResult] {
        results.map { MapResult(mapItem: $0.0, coordinate: $0.1) }
    }

    func makeAnnotation(for result: MapResult) -> some MapContent {
        Annotation(result.mapItem.name ?? "Unknown \(labelSuffix)", coordinate: result.coordinate) {
            VStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(markerColor)
                Text(result.mapItem.name ?? "Unknown \(labelSuffix)")
                    .font(.caption)
                    .fixedSize()
            }
            .onTapGesture {
                routingVM.calculateRoute(from: userLocation, to: result.coordinate)
            }
        }
    }

    var body: some MapContent {
        ForEach(mappedResults) { result in
            makeAnnotation(for: result)
        }
    }
}
