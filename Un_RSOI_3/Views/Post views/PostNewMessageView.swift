//
//  PostNewMessageView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 21.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI
import Combine

struct PostNewMessageView: View {
    @State var text = ""
    @State var userToId = ""
    @State var imageIsAttached = false
    @State var audioIsAttached = false
    @State var imgName = ""
    @State var imgWidth = ""
    @State var imgHeight = ""
    @State var audioName = ""
    @State var audioLenght = ""
    @State var subscriber: AnyCancellable? = nil
    @State var showApiErr = false
    @State var currentApiErr: ApiObjectsManagerError? = nil
    @State var showOkAlert = false
    
    private func postMessage() {
        let msg = Message(text: text, userFromId: UserData.instance.currentUser!.id, userToId: Int(userToId)!, imageId: nil, audioId: nil)
        let data = msg.encodeForPost(withImage: imageIsAttached ? Image(name: imgName, width: Int(imgWidth)!, height: Int(imgHeight)!) : nil, withAudio: audioIsAttached ? Audio(name: audioName, length: Int(audioLenght)!) : nil)!
        subscriber = Message.objects.post(data: data)
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
                Message.objects.add(msg)
                self.showOkAlert.toggle()
            })
    }
    
    private var isMessageInputOk: Bool {
        !text.isEmpty && !userToId.isEmpty && (Int(userToId) != nil)
    }
    private var isAudioInputOk: Bool {
        !audioIsAttached || (!audioName.isEmpty && !audioLenght.isEmpty && (Int(audioLenght) != nil))
    }
    private var isImageInputOk: Bool {
        !imageIsAttached || (!imgName.isEmpty && !imgWidth.isEmpty && !imgHeight.isEmpty && (Int(imgHeight) != nil) && (Int(imgWidth) != nil))
    }
    
    private var canPost: Bool {
        isMessageInputOk && isAudioInputOk && isImageInputOk
    }
    
    var body: some View {
        Form {
            Section{
                TextField("Text", text: self.$text)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(nil)
                
                TextField("User to id", text: self.$userToId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            Section {
                Toggle("Attach image", isOn: self.$imageIsAttached.animation())
                if self.imageIsAttached {
                    PostNewImageView(name: self.$imgName, width: self.$imgWidth, height: self.$imgHeight)
                }
            }
            
            Section {
                Toggle("Attach audio", isOn: self.$audioIsAttached.animation())
                if self.audioIsAttached {
                    PostNewAudioView(name: self.$audioName, lengthStr: self.$audioLenght)
                }
            }
            
            Button("Send") {
                self.postMessage()
            }
            .disabled(!self.canPost)
            .alert(isPresented: self.$showOkAlert) { 
                Alert(title: Text("Message was sent!"))
            }
        }.alert(isPresented: self.$showApiErr) {
            self.getProperApiAlert(err: self.currentApiErr!)
        }
    }
    
}

struct PostNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostNewMessageView()
                .navigationBarTitle("New message")
        }
    }
}
