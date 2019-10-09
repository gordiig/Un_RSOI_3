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
    
    func createButtonTuple(text: String, style: UIAlertAction.Style, action: ((UIAlertAction) -> Void)?) -> AlertButtonTuple

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
    
    func createButtonTuple(text: String, style: UIAlertAction.Style, action: ((UIAlertAction) -> Void)?) -> AlertButtonTuple {
        return (text: text, style: style, action: action)
    }
}


// MARK: - ApiCallerError default alerts
protocol ApiAlertPresentable where Self: AlertPresentable {
    func apiAlert(_ err: ApiCallerError)
}

extension ApiAlertPresentable {
    func apiAlert(_ err: ApiCallerError) {
        switch err {
        case .alamofireError:
            alert(title: "Alamofire alert", message: "Something went wrong with alamofire")
            
        case .cantDecode:
            alert(title: "Can't decode", message: "Can't decode incame data")
            
        case .cantEncode:
            alert(title: "Can't encode", message: "Can't encode data for request")
            
        case .noHostGiven:
            alert(title: "No host given", message: "Enter host for requests in settings")
            
        case .noTokenError:
            alert(title: "No token", message: "Log out and log in again")
            
        case .wrongTokenError:
            alert(title: "Wrong token", message: "Your token is wrong, maybe you are a hacker")
            
        case .unknownError:
            alert(title: "Unknown error", message: "Don't know what to do here")
            
        case.incameError(code: let code, text: let text):
            alert(title: "Code \(code)", message: "Incame message: \"\(text)\"")
        }
    }
    
}
