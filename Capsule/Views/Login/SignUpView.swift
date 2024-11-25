//
//  SignUpView.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-03.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @State private var firstName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSecuredCPW: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @FocusState private var focusedField: Field?
    @Bindable private var authModel = AuthController.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    Spacer()
                    
                    Greetings()
                        .onTapGesture {
                            focusedField = nil
                        }
                    
                    VStack(spacing: 20) {
                        TextField("First Name", text: $firstName)
                            .autocorrectionDisabled(true)
                            .focused($focusedField, equals: .firstName)
                            .onSubmit {
                                focusedField = .email
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("backgroundColor"), lineWidth:2)
                            )
                        
                        MandatoryFields(email: $email, password: $password, signUp: true, focusedField: _focusedField) {
                            focusedField = .confirmPassword
                        }
                        
                        HStack {
                            Group {
                                if isSecuredCPW {
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            authModel.signUp(firstName: firstName, email: email, password: password, confirmPassword: confirmPassword)
                                        }
                                } else {
                                    TextField("Confirm Password", text: $confirmPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            authModel.signUp(firstName: firstName, email: email, password: password, confirmPassword: confirmPassword)
                                        }
                                }
                            }
                            
                            Button {
                                isSecuredCPW.toggle()
                            } label: {
                                Image(systemName: self.isSecuredCPW ? "eye.slash" : "eye")
                                    .accentColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("backgroundColor"), lineWidth:2)
                        )
                    }
                    
                    Button {
                        authModel.signUp(firstName: firstName, email: email, password: password, confirmPassword: confirmPassword)
                    } label: {
                        Text("Sign Up")
                            .foregroundStyle(Color("foregroundColor"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("backgroundColor"))
                            .cornerRadius(10)
                    }
                    
                    Text("-Or Sign up With-")
                    
                    Button {
                        authModel.signInWithGoogle()
                    } label: {
                        HStack {
                            Image(.google)
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            Text("Sign up with Google")
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
                    
                    SignInWithAppleButton(.signUp) { request in
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
                    
                    Spacer()
                    
                    HStack {
                        Text("Already have an account?")
                        
                        NavigationLink {
                            SignInPage()
                        } label: {
                            Text("Sign In")
                                .italic()
                                .underline()
                        }
                        
                    }
                    .font(.callout)
                }
                .padding(.horizontal, 20)
            }
            .alert(isPresented: $authModel.showAlert) {
                Alert(title: Text("Error"), message: Text(authModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    SignUpView()
}
