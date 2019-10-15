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
    
}
