//
//  SearchViewModel.swift
//  Where To?
//
//  Created by Jonathan Amburgy on 2/18/25.
//

import MapKit
import SwiftUI
import Combine

import SwiftUI
import Combine
import MapKit

class SearchViewModel: ObservableObject {
    @Published var queryA: String = ""
    @Published var queryB: String = ""
    @Published var queryC: String = ""
    
    @Published var searchResultsA: [MKMapItem] = []
    @Published var searchResultsB: [MKMapItem] = []
    @Published var searchResultsC: [MKMapItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $queryA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.performSearchA(for: searchText)
            }
            .store(in: &cancellables)
        
        $queryB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.performSearchB(for: searchText)
            }
            .store(in: &cancellables)
        
        $queryC
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.performSearchC(for: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearchA(for query: String) {
        guard !query.isEmpty else {
            self.searchResultsA = []
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                self.searchResultsA = []
                return
            }
            self.searchResultsA = response.mapItems
        }
    }
    
    private func performSearchB(for query: String) {
        guard !query.isEmpty else {
            self.searchResultsB = []
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                self.searchResultsB = []
                return
            }
            self.searchResultsB = response.mapItems
        }
    }
    
    private func performSearchC(for query: String) {
        guard !query.isEmpty else {
            self.searchResultsC = []
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                self.searchResultsC = []
                return
            }
            self.searchResultsC = response.mapItems
        }
    }
}

// local basied searching feature similar to -
// request.region = MKCoordinateRegion(center: <yourCenter>, latitudinalMeters: 10000, longitudinalMeters: 10000)

class RoutingViewModel: ObservableObject {
    @Published var route: MKRoute?
    
    func calculateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile  // or .walking, .transit, etc.
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let route = response?.routes.first, error == nil else {
                print("Route error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.route = route
            }
        }
    }
}
