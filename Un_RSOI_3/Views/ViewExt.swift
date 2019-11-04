//
//  ViewExt.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 19.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    func getProperApiAlert(err: ApiObjectsManagerError) -> Alert {
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
        default:
            return Alert(title: Text("This alert is not implemented in \"getProperApiAlert(err:)\""))
        }
    }
    
}
