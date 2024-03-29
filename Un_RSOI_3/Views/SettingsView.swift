//
//  SettingsView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 19.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

extension Optional where Wrapped == String {
   var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
    
}


struct SettingsView: View {
    @EnvironmentObject var ud: UserData
    @State var showLogInSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("User info:")
                        .font(.headline)
                    HStack {
                        Text("Username:")
                        Spacer()
                        Text(ud.currentUser?.username ?? "No user")
                    }
                    HStack {
                        Text("Email:")
                        Spacer()
                        if (self.ud.currentUser?.email ?? "No user").isEmpty {
                            Text("Not provided")
                        } else {
                            Text(ud.currentUser?.email ?? "No user")
                        }
                    }
                }
                
                Spacer()
                
                TextField("Host", text: $ud.selectedHost.bound)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                Button("Log out") {
                    self.ud.authToken = nil
                    self.ud.currentUser = nil
                }.foregroundColor(Color.red)
            }.padding()
                .sheet(isPresented: $showLogInSheet) {
                    LogInView()
                }
                .navigationBarTitle("Settings")
        }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserData.instance)
            .previewDevice("iPhone Xs")
    }
}
