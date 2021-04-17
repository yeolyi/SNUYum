//
//  AuthManager.swift
//  SNUYum
//
//  Created by SEONG YEOL YI on 2021/04/11.
//

import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var userID: String?
    @Published var userEmail: String?
    
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.userID = user?.uid
            self.userEmail = user?.email
        }
    }
    
    var isLoggedIn: Bool {
        userID != nil
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        objectWillChange.send()
    }   
}
