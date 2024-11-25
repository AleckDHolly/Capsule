//
//  MandatoryFields.swift
//  Respawn Fitness
//
//  Created by Aleck Holly on 2024-09-19.
//

import SwiftUI

struct MandatoryFields: View {
    @Binding var email: String
    @Binding var password: String
    @State private var isSecuredPW: Bool = true
    var signUp: Bool
    
    @FocusState var focusedField: Field?
    var submit: () -> ()
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .onSubmit {
                    focusedField = .password
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("backgroundColor"), lineWidth:2)
                )
            
            HStack {
                Group {
                    if isSecuredPW {
                        SecureField("Password", text: $password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(signUp ? .return : .done)
                            .onSubmit {
                                submit()
                            }
                    } else {
                        TextField("Password", text: $password)
                        
                            .focused($focusedField, equals: .password)
                            .submitLabel(signUp ? .return : .done)
                            .onSubmit {
                                submit()
                            }
                    }
                }
                
                Button {
                    isSecuredPW.toggle()
                } label: {
                    Image(systemName: self.isSecuredPW ? "eye.slash" : "eye")
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
    }
}
