//
//  SiteViewModel.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 17/04/2025.
//

import Foundation

enum SortState: CaseIterable {
  case unsorted, ascending, descending

  var next: SortState {
    let all = Self.allCases // List of all cases [.unsorted, .ascending, .descending]
    guard
      let idx = all.firstIndex(of: self), // Get current index
      all.index(after: idx) < all.endIndex // Check if we are at the end of the array.
    else {
      return all.first! // Return first index if at end of array.
    }
    return all[all.index(after: idx)] // Return next case otherwise.
  }

  mutating func toggle() {
    self = next
  }
}

extension SortState {
  var title: String { // Extension of SortState class, providing state titles for each case.
    switch self {
      case .unsorted:  return "None"
      case .ascending: return "A→Z"
      case .descending: return "Z→A"
    }
  }
}

@MainActor
class SiteListViewModel: ObservableObject {
    // Published variables that are exposed to views.
    @Published private(set) var sites: [Site] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortTitle: String = "None"

    private let service: NetworkService
    private var sortState: SortState = .unsorted
    private var siteCopy: [Site] = [] // Copy of sites to use when we roll back to unsorted state.
    

    init(service: NetworkService = NetworkService()) {
        self.service = service
    }

    func loadSites() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            sites = try await service.fetchSites() // Initial site fetch.
            siteCopy = sites
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Unexpected error: \(error)"
        }
    }
    
    func sortAlphabeticallyAscending() {
        sites.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    func sortAlphabeticallyDescending() {
        sites.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
    }
    
    func handleSortToggle() {
        switch sortState {
        case .unsorted:
            sites = siteCopy
        case .ascending:
            sortAlphabeticallyAscending()
        case .descending:
            sortAlphabeticallyDescending()
        }
        sortTitle = sortState.title
    }
    
    func toggleSort() {
        sortState.toggle()
        handleSortToggle()
    }
}

