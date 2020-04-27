//
//  UIViewController+alert.swift
//  ToDoList
//
//  Created by Jia H Li on 3/9/20.
//  Copyright © 2020 Jia H Li. All rights reserved.
//

import UIKit

extension UIViewController {
    func oneButtonAlert(title: String, message: String) {
        let alertController = UIAlertController(title:  title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style:  .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
