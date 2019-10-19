//
//  MessageViewCell.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 18.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct MessageViewCell: View {
    @ObservedObject var message: Message
    
    var body: some View {
        VStack() {
            Text(message.text)
            
            HStack {
                if UserData.instance.currentUser != nil {
                    SwiftUI.Image(systemName: message.userToId == UserData.instance.currentUser!.id ? "arrow.left" : "arrow.right")
                } else {
                    SwiftUI.Image(systemName: "exclamationmark.triangle")
                }
                
                Spacer()

                if message.imageId != nil {
                    SwiftUI.Image(systemName: "photo")
                }
                if message.audioId != nil {
                    SwiftUI.Image(systemName: "music.note")
                }
            }
        }.padding()
    }
    
}

struct MessageViewCell_Previews: PreviewProvider {
    static var previews: some View {
        MessageViewCell(message: Message(text: "Hello, world!", userFromId: 1, userToId: 1, imageId: "", audioId: ""))
    }
}
