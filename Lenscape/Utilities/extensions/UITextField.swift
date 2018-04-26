//
//  UITextField.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 26/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import Foundation

extension UITextField {
    func setRightViewIcon(icon: UIImage) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: ((self.frame.height) * 0.70), height: ((self.frame.height) * 0.70)))
        btnView.setImage(icon, for: .normal)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        self.rightViewMode = .always
        self.rightView = btnView
    }
}
