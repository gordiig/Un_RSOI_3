//
//  MessageView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 16.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    @State var message: Message
    
    var body: some View {
        VStack {
            VStack {
                Text("Message text:").font(.largeTitle)
                Text(self.message.text)
            }
            Divider()
            
            VStack {
                Text("From:").font(.largeTitle)
                Button(action: {
                    
                }) {
                    Text(self.message.userFrom?.username ?? "No user given")
                }
            }
            Divider()
            
            VStack {
                Text("To:").font(.largeTitle)
                Button(action: {
                    
                }) {
                    Text(self.message.userTo?.username ?? "No user given")
                }
            }
            Divider()
            
            if !self.message.isComplete {
                Text("Message is incomplete!")
            } else {
                if self.message.imageId != nil {
                    VStack {
                        Text("Image:").font(.largeTitle)
                        Button(action: {
                            
                        }) {
                            Text(self.message.image?.name ?? "No image given")
                        }
                    }
                    Divider()
                }
                
                if self.message.audioId != nil {
                    VStack {
                        Text("Audio:").font(.largeTitle)
                        Button(action: {
                            
                        }) {
                            Text(self.message.audio?.name ?? "No audio given")
                        }
                    }
                    Divider()
                }
            }
        }.padding()
    }
    
}

struct MessageView_Previews: PreviewProvider {

    fileprivate static let testData = TestData.instance
    
    static var previews: some View {
        MessageView(message: testData.message)
    }
}


fileprivate class TestData {
    static var instance = TestData()
    
    private let userFromDict = ["username": "username from is it", "id": 0, "email": "from@gmail.com"] as Any
    private let userToDict = ["username": "username to is here", "id": 1, "email": "to@gmail.com"] as Any
    private let audioDict = ["uuid": UUID(), "name": "Take_on_me.mp3", "length": 82] as Any
    private let imageDict = ["uuid": UUID(), "name": "coolImg.jpg", "image_size": "720x480"] as Any
    
    private(set) var userTo: User
    private(set) var userFrom: User
    private(set) var audio: Audio
    private(set) var image: Image
    private(set) var message: Message
    
    private init() {
        let userToJson = try! JSONSerialization.data(withJSONObject: userToDict)
        let userFromJson = try! JSONSerialization.data(withJSONObject: userFromDict)
        let audioJson = try! JSONSerialization.data(withJSONObject: audioDict)
        let imageJson = try! JSONSerialization.data(withJSONObject: imageDict)
        
        let decoder = JSONDecoder()
        self.userTo = try! decoder.decode(User.self, from: userToJson)
        self.userFrom = try! decoder.decode(User.self, from: userFromJson)
        self.audio = try! decoder.decode(Audio.self, from: audioJson)
        self.image = try! decoder.decode(Image.self, from: imageJson)
        
        let messageJson = try! JSONSerialization.data(withJSONObject: ["uuid": UUID(), "text": "Hello world!", "image_uuid": image.id, "audio_id": audio.id, "from_user_id": userFrom.id, "to_user_id": userTo.id])
        self.message = try! decoder.decode(Message.self, from: messageJson)
        
    }

}
