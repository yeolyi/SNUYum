//
//  SignInWithAppleToFirebase.swift
//  LoginWithAppleFirebaseSwiftUI
//
//  Created by Joseph Hinkle on 12/15/19. Thank you!!
//  Copyright © 2019 Joseph Hinkle. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct SignInWithApple: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        if colorScheme == .light {
            SignInWithAppleLight()
        } else {
            SignInWithAppleDark()
        }
    }
}

final class SignInWithAppleLight: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: .default, style: .black)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

final class SignInWithAppleDark: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(type: .default, style: .white)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

enum SignInWithAppleToFirebaseResponse {
    case success
    case error
}

final class SignInWithAppleToFirebase: UIViewControllerRepresentable {
    private var appleSignInDelegates: SignInWithAppleDelegates! = nil
    private let onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> Void)
    private var currentNonce: String?
    
    init(_ onLoginEvent: @escaping ((SignInWithAppleToFirebaseResponse) -> Void)) {
        self.onLoginEvent = onLoginEvent
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIHostingController(rootView: SignInWithApple().onTapGesture(perform: startSignInWithAppleFlow))
        return vc as UIViewController
    }
    
    func updateUIViewController(_ uiView: UIViewController, context: Context) {
        
    }
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        appleSignInDelegates =
            SignInWithAppleDelegates(window: nil, currentNonce: nonce, onLoginEvent: self.onLoginEvent)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = appleSignInDelegates
        authorizationController.presentationContextProvider = appleSignInDelegates
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset =
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
                if length == 0 {
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
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

class SignInWithAppleDelegates: NSObject {
    private let onLoginEvent: ((SignInWithAppleToFirebaseResponse) -> Void)
    private weak var window: UIWindow!
    private var currentNonce: String? // Unhashed nonce.
    init(
        window: UIWindow?, currentNonce: String,
        onLoginEvent: @escaping ((SignInWithAppleToFirebaseResponse) -> Void)
    ) {
        self.window = window
        self.currentNonce = currentNonce
        self.onLoginEvent = onLoginEvent
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                self.onLoginEvent(.error)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                self.onLoginEvent(.error)
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (_, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    self.onLoginEvent(.error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                self.onLoginEvent(.success)
            }
        }
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}
