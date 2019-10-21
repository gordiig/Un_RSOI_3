//
//  PostNewImageView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 21.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct PostNewImageView: View {
    @Binding var name: String
    @Binding var width: String
    @Binding var height: String
    
    var canPost: Bool {
        !name.isEmpty && !width.isEmpty && !height.isEmpty && (Int(height) != nil) && (Int(width) != nil)
    }
    
    var body: some View {
        VStack {
            TextField("Name", text: self.$name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                TextField("Width", text: self.$width)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("x")
                TextField("Height", text: self.$height)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }.padding()
    }
    
}

struct PostNewImageView_Previews: PreviewProvider {
    static var previews: some View {
        PostNewImageView(name: .constant(""), width: .constant(""), height: .constant(""))
    }
}
