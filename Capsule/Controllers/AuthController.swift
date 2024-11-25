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
import AuthenticationServices
import CryptoKit
import SwiftUI
import FirebaseDatabaseInternal

@Observable
class AuthController {
    var alertMessage: String = ""
    var showAlert: Bool = false
    var currentNonce: String?
    var user: User?
    var users: [FirebaseUser] = []
    let databaseRef = Database.database().reference()
    
    private var authListener: AuthStateDidChangeListenerHandle?
    
    static let shared = AuthController()
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
        
        if !hasLaunchedBefore {
            do {
                try Auth.auth().signOut()
                hasLaunchedBefore = true
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }
        
        authListener = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
        }
    }
    
    func addUser(user: User?) {
        let locManager = LocationManager.shared
        
        //Recuperer le location a partir du service
        guard let location = locManager.location else {
            return
        }
        
        guard let userID = user?.uid else {
            return
        }
        
        let db = databaseRef.child(userID)
        
        let images: [String] = [
            "person","person.fill","person.crop.circle","person.circle","person.circle.fill","person.crop.rectangle","person.crop.square"
        ]
        
        let userExists = users.contains { $0.id == userID }
        
        if !userExists {
            db.setValue(["id": userID, "name": self.user?.displayName ?? "User", "avatar": images.randomElement() ?? "person", "latitude": location.latitude, "longitude": location.longitude])
        }
    }
    
    func fetchUsers(){
        databaseRef.observe(.value) { snapshot in
            var newUsers: [FirebaseUser] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let valueDict = childSnapshot.value as? [String: Any],
                   let id = valueDict["id"] as? String,
                   let name = valueDict["name"] as? String,
                   let avatar = valueDict["avatar"] as? String,
                   let latitude = valueDict["latitude"] as? Double,
                   let longitude = valueDict["longitude"] as? Double {
                    
                    let user = FirebaseUser(
                        id: id,
                        name: name,
                        avatar: avatar,
                        latitude: latitude,
                        longitude: longitude
                    )
                    newUsers.append(user)
                }
            }
            self.users = newUsers
            print(self.users)
        }
    }
    
    //MARK: Regular sign in and sign up
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
                
                self.user?.displayName = firstName
                self.addUser(user: self.user)
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
                self.addUser(user: self.user)
            }
        }
    }
    
    //MARK: Sign IN and UP W/ Google
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
                
                self.user?.displayName = user.user.profile?.givenName
                print("User signed in with Firebase: \(user.user.profile?.name ?? "User")")
                self.addUser(user: self.user)
            }
        }
    }
    
    //MARK: Sign in with Apple
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func handleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSuccessfulLogin(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    return
                }
                
                // Update the local user variable with the signed-in user
                self.user = authResult?.user
                self.addUser(user: self.user)
                
                // Extract full name from Apple credentials
                if let fullName = appleIDCredential.fullName {
                    let displayName = [fullName.givenName]
                        .compactMap { $0 } // Filter out any nil values
                        .joined(separator: " ") // Join names with a space
                    
                    let changeRequest = self.user?.createProfileChangeRequest()
                    changeRequest?.displayName = displayName
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("Failed to update display name: \(error.localizedDescription)")
                        } else {
                            print("Display name successfully updated to \(displayName)")
                        }
                    }
                }
            }
        }
    }
    
    func handleLoginError(with error: Error) {
        print("Could not authenticate: \\(error.localizedDescription)")
    }
    
    //MARK: SIGN OUT
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
