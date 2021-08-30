//
//  ContentView.swift
//  CloseBuy
//
//  Created by Connor A Lynch on 30/08/2021.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack {
            switch authVM.authStatus {
            case .signedIn(let user):
                Text("Hello: \(user.userDetails.fullname)")
            case .signedOut:
                OnboardingView()
            case .loading:
                ProgressView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
