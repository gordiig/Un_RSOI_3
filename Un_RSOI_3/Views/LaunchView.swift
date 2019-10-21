//
//  LaunchView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 20.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var ud: UserData
    
//    @ViewBuilder
    var body: some View {
        VStack {
            if self.ud.isLoggedIn {
                MainTabBarView()
                    .transition(.scale)
            } else {
                LogInView()
                    .transition(.scale)
            }
        }.animation(.default)
    }
    
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .environmentObject(UserData.instance)
            .previewDevice("iPhone Xs")
    }
}
