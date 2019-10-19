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
    @State private var refreshSubscriber: AnyCancellable?
    
    @ObservedObject var mm = Message.objects
    @State private var toggleError = false
    @State private var incameError: ApiObjectsManagerError?
    @State private var didTapOnMessage = false
    
    // MARK: - Methods
    private func refresh() {
        self.refreshSubscriber = mm.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (competion) in
                switch competion {
                case .finished:
                    break
                case .failure(let err):
                    self.incameError = err
                    self.toggleError.toggle()
                }
            }) { (msgs) in
                self.mm.override(msgs)
            }
    }
    
    private func getProperAlert() -> Alert {
        guard let err = incameError else {
            return Alert(title: Text("\(self.mm.count) messages came"))
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
            List {
                ForEach(mm.all) { (message: Message) in
                    MessageViewCell(message: message)
                        .onTapGesture {
                            self.didTapOnMessage.toggle()
                        }
                        .sheet(isPresented: self.$didTapOnMessage, onDismiss: nil) {
                            MessageView(message: message)
                        }
                }
            }.navigationBarTitle("\(self.mm.count) messages")
                .navigationBarItems(trailing: Button(action: { self.refresh() }, label: { Text("Refresh") }))
        }.alert(isPresented: $toggleError) {
            self.getProperAlert()
        }
        .onAppear() {
            self.refresh()
        }
    }
    
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
