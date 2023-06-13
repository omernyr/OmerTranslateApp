//
//  Extension+UIButton.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 13.06.2023.
//

import UIKit

extension UIButton {
    
    func buildButton(contentMode: ContentMode?, tintColor: UIColor, cornerRadius: CGFloat?, imageViewString: String) {
        
        self.contentMode = contentMode ?? .center
        self.tintColor = tintColor
        self.layer.cornerRadius = cornerRadius ?? 0.0
        self.setImage(UIImage(systemName: imageViewString), for: .normal)
    }
    
}
