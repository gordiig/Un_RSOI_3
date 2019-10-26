//
//  AudioView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 20.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct AudioView: View {
    @ObservedObject var audio: Audio
    
    var body: some View {
        VStack {
            HStack {
                Text("Name:")
                Spacer()
                Text(self.audio.name)
            }
            
            HStack {
                Text("Length:")
                Spacer()
                Text(self.audio.formattedLength)
            }
            Spacer()
        }.padding()
    }
    
}

struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        AudioView(audio: Audio(name: "Test audio", length: 68))
    }
}
