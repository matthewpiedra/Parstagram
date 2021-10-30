//
//  UIImageView.swift
//  Parstagram
//
//  Created by Matthew Piedra on 10/29/21.
//

import Foundation
import UIKit

extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
