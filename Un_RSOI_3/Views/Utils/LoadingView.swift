//
//  LoadingView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 19.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isShowing: Bool
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            ActivityIndicator(isAnimating: $isShowing)
            Text("Loading...")
            Button(action: {
                self.onCancel()
                self.isShowing = false
            }) {
                Text("Cancel")
            }.padding(.top, 8)
        }.padding()
            .background(Color.secondary.colorInvert().opacity(0.5))
            .cornerRadius(10)
    }
    
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isShowing: .constant(true), onCancel: {})
    }
}
