//
//  SignInPage.swift
//  Respawn Fitness
//
//  Created by Aleck Holly on 2024-09-19.
//

import SwiftUI
import AuthenticationServices

struct SignInPage: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @FocusState private var focusedField: Field?
    @Bindable private var authModel = AuthController.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    Greetings()
                        .onTapGesture {
                            focusedField = nil
                        }
                    
                    MandatoryFields(email: $email, password: $password, signUp: false) {
                        authModel.signIn(email: email, password: password)
                    }
                    
                    Button {
                        authModel.signIn(email: email, password: password)
                    } label: {
                        Text("Sign In")
                            .foregroundStyle(Color("foregroundColor"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("backgroundColor"))
                            .cornerRadius(10)
                    }
                    
                    Text("-Or Sign in With-")
                    
                    Button {
                        authModel.signInWithGoogle()
                    } label: {
                        HStack {
                            Image(.google)
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("Sign in with Google")
                                .foregroundStyle(Color("foregroundColor"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("backgroundColor"))
                        .cornerRadius(10)
                    }
                    .frame(height: 50)
                    .padding(.bottom, -20)
                    
                    SignInWithAppleButton(.signIn) { request in
                        authModel.handleRequest(request)
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            authModel.handleSuccessfulLogin(authorization)
                        case .failure(let error):
                            authModel.handleLoginError(with: error)
                        }
                    }
                    .signInWithAppleButtonStyle(isDarkMode ? .white : .black)
                    .frame(height: 50)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .alert(isPresented: $authModel.showAlert) {
                Alert(title: Text("Error"), message: Text(authModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


#Preview {
    SignInPage()
}
