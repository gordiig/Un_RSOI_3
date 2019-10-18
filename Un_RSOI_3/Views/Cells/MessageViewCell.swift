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
        Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MessageViewCell_Previews: PreviewProvider {
    static var previews: some View {
        MessageViewCell(message: Message(text: "Hello, world!", userFromId: 1, userToId: 1, imageId: UUID(), audioId: UUID()))
    }
}
