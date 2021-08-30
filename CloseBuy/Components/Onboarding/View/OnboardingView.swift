//
//  OnboardingView.swift
//  CloseBuy
//
//  Created by Connor A Lynch on 30/08/2021.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct OnboardingView: View {
    
    @State var currentNonce: String?
    
    var body: some View {
        VStack {
            SignInWithAppleButton(
                onRequest: { request in
                    continueWithApple(with: request)
                },
                onCompletion: { result in
                    signInFlowApple(with: result)
                }
            )
        }
    }
    
    @available(iOS 13, *)
    func continueWithApple(with request: ASAuthorizationAppleIDRequest){
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    @available(iOS 13, *)
    func signInFlowApple(with result: Result<ASAuthorization, Error>){
        switch result {
        case .success(let result):
            switch result.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                // Initialize a Firebase credential.
                
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                
                AuthViewModel.shared.continueWithApple(with: credential)
            // Sign in with Firebase.
            default:
                return
            }
        case .failure(let error):
            print("DEBUG: \(error.localizedDescription)")
        }
    }
}

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
