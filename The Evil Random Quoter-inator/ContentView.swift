//
//  ContentView.swift
//  The Evil Random Quoter-inator
//
//  Created by Izabela Marcinkowska on 2024-12-04.
//

import SwiftUI

struct ContentView: View {
    @State private var currentQuote: Quote?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://zenquotes.io/api/random") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode([Quote].self, from: data)
            
            await MainActor.run {
                if let quote = decodedResponse.first {
                    currentQuote = quote
                } else {
                    errorMessage = "No quote received"
                }
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Error loading quote: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    var body: some View {
        VStack (spacing: 20) {
            Button("Get quote") {
                Task {
                    await loadData()
                }
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            } else if let quote = currentQuote {
                VStack(spacing: 10) {
                    Text(quote.q)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                    
                    Text("- \(quote.a)")
                        .font(.subheadline)
                        .italic()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
}
