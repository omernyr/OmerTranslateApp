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
        self.text = "Sınırların ötesine geç"
        self.font = UIFont(name: "Gilroy-Medium", size: 19.0)
        self.layer.cornerRadius = 20.0
        self.textColor = .init(hexString: "#33272a")
        self.textAlignment = .center
        self.backgroundColor = .clear
    }
    
}
