//
//  UIViewControllerExt.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import UIKit


// MARK: - Alerts
protocol AlertPresentable where Self: UIViewController {
    // MARK: - Alert
    typealias AlertButtonTuple = (text: String, style: UIAlertAction.Style,  action: ((UIAlertAction) -> Void)?)
    
    func alert(title: String, message: String, buttons: [AlertButtonTuple])
    
    func createButtonTuple(_ text: String, _ style: UIAlertAction.Style, _ action: ((UIAlertAction) -> Void)?) -> AlertButtonTuple

}

extension AlertPresentable {
    func alert(title: String, message: String = "", buttons: [AlertButtonTuple] = [("Ok", .default, nil)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for button in buttons {
            let alertAction = UIAlertAction(title: button.text, style: .default, handler: button.action)
            alert.addAction(alertAction)
        }
        self.present(alert, animated: true)
    }
    
    func createButtonTuple(_ text: String, _ style: UIAlertAction.Style, _ action: ((UIAlertAction) -> Void)?) -> AlertButtonTuple {
        return (text: text, style: style, action: action)
    }
}


// MARK: - ApiCallerError default alerts
protocol ApiAlertPresentable where Self: AlertPresentable {
    func apiAlert(_ err: ApiObjectsManagerError)
}

extension ApiAlertPresentable {
    func apiAlert(_ err: ApiObjectsManagerError) {
        switch err {
        case .decodeError:
            alert(title: "Decode error")
        case .encodeError:
            alert(title: "Encode error")
        case .noHostGiven:
            alert(title: "No host given", message: "Go to settings to set host")
        case .noTokenGiven:
            alert(title: "No token given", message: "Log off and log in again")
        case .codedError(let code, let message):
            alert(title: "Error code \(code)", message: message)
        case .unknownError:
            alert(title: "Unknown error")
        }
    }
    
}
