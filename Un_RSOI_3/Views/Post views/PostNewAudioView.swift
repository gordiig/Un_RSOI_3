//
//  PostNewAudioView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 21.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct PostNewAudioView: View {
    @Binding var name: String
    @Binding var lengthStr: String
    
    var body: some View {
        VStack {
            TextField("Name", text: self.$name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Length (in seconds)", text: self.$lengthStr)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
        }.padding()
    }
}

struct PostNewAudioView_Previews: PreviewProvider {
    static var previews: some View {
        PostNewAudioView(name: .constant(""), lengthStr: .constant(""))
            .previewDevice("iPhone Xs")
    }
}
