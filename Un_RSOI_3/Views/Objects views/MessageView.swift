//
//  MessageView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 16.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI
import Combine

struct MessageView: View {
    private enum WhatSheetToShow {
        case audio
        case image
        case userTo
        case userFrom
    }
    
    @ObservedObject var message: Message
    @State var showApiErr = false
    @State var currentApiErr: ApiObjectsManagerError?
    @State var messageSubscriber: AnyCancellable?
    @State var showSheet = false
    @State private var whatSheetToShow = WhatSheetToShow.image
    
    private func showImage() {
        whatSheetToShow = .image
        showSheet.toggle()
    }
    private func showAudio() {
        whatSheetToShow = .audio
        showSheet.toggle()
    }
    private func showUserTo() {
        whatSheetToShow = .userTo
        showSheet.toggle()
    }
    private func showUserFrom() {
        whatSheetToShow = .userFrom
        showSheet.toggle()
    }
    
    private func getSheetToShow() -> AnyView {
        switch whatSheetToShow {
        case .image:
            return AnyView(ImageView(image: self.message.image!))
        case .audio:
            return AnyView(AudioView(audio: self.message.audio!))
        case .userTo:
            return AnyView(UserView(user: self.message.userTo!))
        case .userFrom:
            return AnyView(UserView(user: self.message.userFrom!))
        }
    }
    
    private func getAllInfo() {
        messageSubscriber = Message.objects.fetch(id: message.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let err):
                    self.currentApiErr = err
                    self.showApiErr.toggle()
                case .finished:
                    break
                }
            }, receiveValue: { (msg) in
                Message.objects.override(self.message, with: msg)
            })
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("Message text:").font(.largeTitle)
                    Text(self.message.text)
                }
                Divider()

                VStack {
                    Text("From:").font(.largeTitle)
                    Button(action: {
                        self.showUserFrom()
                    }) {
                        Text(self.message.userFrom?.username ?? "No user given")
                    }
                }
                Divider()

                VStack {
                    Text("To:").font(.largeTitle)
                    Button(action: {
                        self.showUserTo()
                    }) {
                        Text(self.message.userTo?.username ?? "No user given")
                    }
                }
                Divider()

                if self.message.image != nil {
                    VStack {
                        Text("Image:").font(.largeTitle)
                        Button(action: {
                            self.showImage()
                        }) {
                            Text(self.message.image!.name)
                        }
                    }
                    Divider()
                }

                if self.message.audio != nil {
                    VStack {
                        Text("Audio:").font(.largeTitle)
                        Button(action: {
                            self.showAudio()
                        }) {
                            Text(self.message.audio!.name)
                        }
                    }
                    Divider()
                }

                Spacer()
            }.padding()
        }.navigationBarTitle("Message")
        .alert(isPresented: self.$showApiErr) {
            self.getProperApiAlert(err: self.currentApiErr!)
        }
        .onAppear {
            if !self.message.isComplete { self.getAllInfo() }
        }
        .sheet(isPresented: self.$showSheet, content: {
            self.getSheetToShow()
        })
    }
    
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: Message(text: "Hello", userFromId: 0, userToId: 0, imageId: nil, audioId: nil))
    }
}

