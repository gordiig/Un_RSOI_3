//
//  LogInView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 20.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI
import Combine

struct LogInView: View {
    @EnvironmentObject var ud: UserData
    @State var username = ""
    @State var password = ""
    @State var subscriber: AnyCancellable? = nil
    @State var userDataSubscriber: AnyCancellable? = nil
    @State var showApiError = false
    @State var apiError: ApiObjectsManagerError?
    
    private func logIn() {
        subscriber = AuthService.instance.authenticate(username: username, password: password)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let err):
                    self.apiError = err
                    self.showApiError.toggle()
                case .finished:
                    break
                }
            }, receiveValue: { (token) in
                self.ud.authToken = token
                self.userDataSubscriber = AuthService.instance.getUserInfo(token: token)
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let err):
                            self.apiError = err
                            self.showApiError.toggle()
                        case .finished:
                            break
                        }
                    }, receiveValue: { (user) in
                        self.ud.currentUser = user
                    })
            })
    }
    
    private func signUp() {
        
    }
    
    var body: some View {
        VStack {
            TextField("Host", text: self.$ud.selectedHost.bound)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
            
            TextField("Username", text: self.$username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            TextField("Password", text: self.$password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Log in") {
                self.logIn()
            }
            
            Spacer()
            
            Button("Sign up") {
                self.signUp()
            }
        }.padding()
            .alert(isPresented: self.$showApiError) {
                self.getProperApiAlert(err: self.apiError ?? ApiObjectsManagerError.unknownError)
            }
    }
    
}
    

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView().environmentObject(UserData.instance)
            .previewDevice("iPhone Xs")
    }
}
