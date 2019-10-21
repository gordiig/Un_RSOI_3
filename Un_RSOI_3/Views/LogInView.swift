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
    
    private func logIn() {
        self.ud.authToken = ""
        self.ud.currentUser = User(username: "", email: "")
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
    }
    
}
    

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView().environmentObject(UserData.instance)
            .previewDevice("iPhone Xs")
    }
}
