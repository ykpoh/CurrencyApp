//
//  UIViewController+Extensions.swift
//  CurrencyApp
//
//  Created by YK Poh on 17/06/2022.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert( _ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
