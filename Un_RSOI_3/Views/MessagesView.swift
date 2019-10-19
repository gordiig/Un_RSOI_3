//
//  MessagesView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 18.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI
import Combine

struct MessagesView: View {
    @ObservedObject var mm = Message.objects
    @State private var toggleError = false
    @State private var incameMessagesCount = 0
    @State private var incameError: ApiObjectsManagerError?
    @State private var didTapOnMessage = false
    
    // MARK: - Methods
    private func refresh() {
        let _ = mm.fetchAll().sink(receiveCompletion: { (competion) in
            switch competion {
            case .finished:
                break
            case .failure(let err):
                self.incameError = err
                self.toggleError.toggle()
            }
        }) { (msgs) in
            self.incameMessagesCount = msgs.count
            self.incameError = nil
            self.toggleError.toggle()
        }
    }
    
    private func getProperAlert() -> Alert {
        guard let err = incameError else {
            return Alert(title: Text("\(incameMessagesCount) messages came"))
        }
        switch err {
        case .decodeError:
            return Alert(title: Text("Decode error"))
        case .encodeError:
            return Alert(title: Text("Encode error"))
        case .noHostGiven:
            return Alert(title: Text("No host given"), message: Text("Go to settings to set host"))
        case .noTokenGiven:
            return Alert(title: Text("No token given"), message: Text("Log off and log in again"))
        case .codedError(let code, let message):
            return Alert(title: Text("Error code \(code)"), message: Text(message))
        case .unknownError:
            return Alert(title: Text("Unknown error"))
        }
    }
    
    // MARK: - body
    var body: some View {
        NavigationView {
            ForEach(mm.all) { (message: Message) in
                MessageViewCell(message: message)
                    .onTapGesture {
                        self.didTapOnMessage.toggle()
                    }
                    .sheet(isPresented: self.$didTapOnMessage, onDismiss: nil) {
                        MessageView(message: message)
                    }
            }.navigationBarTitle("Messages")
                .navigationBarItems(trailing: Button(action: { self.refresh() }, label: { Text("Refresh") }))
        }.alert(isPresented: $toggleError) {
            self.getProperAlert()
        }
    }
    
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
