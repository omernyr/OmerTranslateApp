//
//  ResultTextView.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 15.06.2023.
//

import UIKit

class ResultTextView: UITextView {
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
        
    }

    private func setupTextView() {
        
       self.font = UIFont(name: "Gilroy-Medium", size: 19.0)
       self.layer.cornerRadius = 10.0
       self.textColor = .black
       self.textAlignment = .center
       self.backgroundColor = UIColor(hexString: "FEF9EF")
    }
    
    
}
