//
//  ImageView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 20.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var image: Image
    
    var body: some View {
        VStack {
            HStack {
                Text("Name")
                Spacer()
                Text(self.image.name)
            }
            
            HStack {
                Text("Width")
                Spacer()
                Text("\(self.image.width)")
            }
            
            HStack {
                Text("Height")
                Spacer()
                Text("\(self.image.height)")
            }
            Spacer()
        }.padding()
    }
    
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: Image(name: "Test image", width: 100, height: 200))
    }
}
