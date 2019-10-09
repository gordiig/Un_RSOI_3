//
//  UIViewControllerExt.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    // MARK: - Alert
    typealias AlertButtonTuple = (text: String, style: UIAlertAction.Style,  action: ((UIAlertAction) -> Void)?)
    
    class func alert(on vc: UIViewController = self, title: String, message: String = "", buttons: [AlertButtonTuple] = [("Ok", .default, nil)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for button in buttons {
            let alertAction = UIAlertAction(title: button.text, style: .default, handler: button.action)
            alert.addAction(alertAction)
        }
        vc.present(alert, animated: true)
    }
    
    class func createButtonTuple(text: String, style: UIAlertAction.Style, action: ((UIAlerAction) -> Void)?) -> AlertButtonTuple {
        return (text: text, style: style, action: action)
    }

}
