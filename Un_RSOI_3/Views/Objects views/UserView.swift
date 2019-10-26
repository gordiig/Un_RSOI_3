//
//  UserView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 20.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var user: User
    
    var body: some View {
        VStack {
            HStack {
                Text("Username:")
                Spacer()
                Text(self.user.username)
            }
            
            HStack {
                Text("Email:")
                Spacer()
                Text(self.user.email.isEmpty ? "Not provided" : self.user.email)
            }
            
            Spacer()
        }.padding()
    }
    
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: User(username: "Username", email: "gg@gmail.com"))
    }
}
