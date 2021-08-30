//
//  AuthViewModel.swift
//  CloseBuy
//
//  Created by Connor A Lynch on 30/08/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum AuthStatus {
    case signedOut
    case loading
    case signedIn(user: User)
}

class AuthViewModel: ObservableObject {
    
    @Published var authStatus: AuthStatus = .signedOut
    
    static var shared = AuthViewModel()
    
    init(){
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.fetchUser(with: user.uid) { result in
                    switch result {
                    case .success(let user):
                        self?.authStatus = .signedIn(user: user)
                        print(user.userDetails.fullname)
                    case .failure(let error):
                        print("DEBUG: \(error.localizedDescription)")
                    }
                }
            }else{
                self?.authStatus = .signedOut
            }
            
        }
    }
    
    func continueWithApple(with credential: OAuthCredential){
        self.authStatus = .loading
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                self?.authStatus = .signedOut
                print("DEBUG: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func fetchUser(with id: String, completion: @escaping (Result<User, Error>) -> Void){
        Firestore.firestore().document(id).getDocument { snapshot, error in
            if let document = snapshot, document.exists {
                do {
                    guard let user = try document.data(as: User.self) else { return }
                    completion(.success(user))
                }catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    
}
