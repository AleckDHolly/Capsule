//
//  AuthController.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-03.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

@Observable
class AuthViewController {
    var isLoggedIn: Bool = false
    var alertMessage: String = ""
    var showAlert: Bool = false
    
    private var authListener: AuthStateDidChangeListenerHandle?
    
    static let shared = AuthViewController()
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
            if Auth.auth().currentUser != nil {
                print("User is logged in.")
                self.isLoggedIn = true
            } else {
                print("User is not logged in")
                self.isLoggedIn = false
            }
        }
    }
    
    
    func signUp(firstName: String, email: String, password: String, confirmPassword: String) {
        // Check if any field is empty
        guard !firstName.isEmpty else {
            alertMessage = "Please enter your first name."
            showAlert = true
            return
        }
        
        guard firstName.count >= 2 else {
            alertMessage = "First name must be at least 2 characters long."
            showAlert = true
            return
        }
        
        guard !email.isEmpty else {
            alertMessage = "Please enter your email address."
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertMessage = "Please enter a password."
            showAlert = true
            return
        }
        
        guard !confirmPassword.isEmpty else {
            alertMessage = "Please confirm your password."
            showAlert = true
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: confirmPassword) { result, error in
            if let error {
                print(error.localizedDescription)
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            } else {
                print("User created successfully")
                
                // Set the display name (first name) for the user
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = firstName
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Failed to update display name: \(error.localizedDescription)")
                        self.alertMessage = "Failed to update display name."
                        self.showAlert = true
                    } else {
                        print("Display name updated successfully")
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let error {
                print(error.localizedDescription)
                self.alertMessage = "The email or password is not valid."
                self.showAlert = true
            } else {
                print("User signed in successfully")
            }
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        guard let rootViewController = window?.rootViewController else { return }
        
        // Perform the Google sign-in process
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            if let error = error {
                print("Google sign-in error: \(error.localizedDescription)")
                return
            }
            
            // Handle the user successfully signed in
            guard let user = user else {
                print("No user information returned from Google Sign-In")
                return
            }
        
            // Access user information, e.g., name, email
            print("User signed in: \(user.user.profile?.name ?? "User")")
            
            // Access the GIDGoogleUser object and its credentials
            let signInResult = user.user
            guard let idToken = signInResult.idToken?.tokenString else {
                print("No token information available from Google Sign-In")
                return
            }
            let accessToken = signInResult.accessToken.tokenString
            
            // Create a credential with the obtained ID token and access token
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) {result, error in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    return
                }
                
                // User is signed in to Firebase
                print("User signed in with Firebase: \(user.user.profile?.name ?? "User")")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
