//
//  UIAlertController+Extensions.swift
//  Common
//
//  Created by Yuriy Levytskyy on 9/21/18.
//  Copyright © 2018 Yuriy Levytskyy. All rights reserved.
//

import UIKit
import RxSwift

public extension UIAlertController {
    public struct AlertAction {
        var title: String
        var style: UIAlertActionStyle
        
        init(title: String, style: UIAlertActionStyle = .default) {
            self.title = title
            self.style = style
        }
    }
    
    public static func present(
        in viewController: UIViewController,
        title: String?,
        message: String?,
        style: UIAlertControllerStyle,
        actions: [AlertAction])
        -> Observable<Int>
    {
        return Single.create { observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            actions.enumerated().forEach { index, action in
                let action = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer(.success(index))
                }
                alertController.addAction(action)
            }
            
            viewController.present(alertController, animated: true, completion: nil)
            return Disposables.create { alertController.dismiss(animated: true, completion: nil) }
            }.asObservable()
    }
    
    public static func confirmationAlert(in viewController: UIViewController, title: String?, message: String?, yes: String = "Так", no: String = "Ні") -> Observable<Bool> {
        let actions = [
            AlertAction(title: yes, style: .destructive),
            AlertAction(title: no)
        ]
        
        return present(in: viewController, title: title, message: message, style: .alert, actions: actions)
            .map { $0 == 0 }
    }
}

