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
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("User info:")
                        .font(.footnote)
                    HStack {
                        Text("Username:")
                        Spacer()
                        Text(ud.currentUser?.username ?? "No user")
                    }
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text(ud.currentUser?.email ?? "No user")
                    }
                    NavigationLink(destination: MessagesView()) {
                        Text("Change")
                    }
                }
                
                Spacer()
                
                TextField("Host", text: $ud.selectedHost.bound)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Log out")
                }
            }.padding()
        }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
