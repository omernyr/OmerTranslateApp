//
//  Extension+UILabel.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 15.06.2023.
//

import UIKit

extension UILabel {
    
    func buildLabel(text: String?, textColor: UIColor?, fontName: String?, fontSize: CGFloat?, alignment: NSTextAlignment?) {
        
        self.text = text
        self.textColor = textColor
        self.font = UIFont(name: fontName ?? "Gilroy-Medium", size: fontSize ?? 0.0)
        self.textAlignment = alignment ?? .center
        
    }
    
}
