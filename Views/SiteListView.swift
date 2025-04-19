//
//  SiteListView.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 17/04/2025.
//

import SwiftUI

struct SiteListView: View {
    @StateObject private var vm = SiteListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else if let error = vm.errorMessage { // Case for error in SiteListViewModel
                    VStack {
                        Text(error).foregroundColor(.red)
                        Button("Retry") {
                            Task { await vm.loadSites() } // Retry on button press.
                        }
                    }
                } else {
                    List(vm.sites) { site in
                        SiteRowView(site: site)
                            .onTapGesture { open(url: site.url) }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Websites")
            .toolbar {
                Button("Sorting by: \(vm.sortTitle)") { vm.toggleSort() }
            }
        }
        .task { await vm.loadSites() }
    }

    private func open(url: URL) {
        UIApplication.shared.open(url) // Open a new safari window with requested URL.
    }
}
