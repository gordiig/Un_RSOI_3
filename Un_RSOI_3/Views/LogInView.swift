//
//  ContentView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 02.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct LogInView: View {
    // MARK: - Variables and states
    private var requester = AuthApiCaller.instance
    
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    
    // MARK: - Auth
    private func authenticate() {
        requester.authenticate(username: username, password: password) { result in
            switch result {
            case .success(let token):
                UserData.instance.authToken = token
                // TODO: - Переход на другой вью

            case .failure(let err):
                self.showAlert.toggle()
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button(action: {
                self.authenticate()
            }) {
                Text("Log in")
            }
        }.padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert came"))
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
