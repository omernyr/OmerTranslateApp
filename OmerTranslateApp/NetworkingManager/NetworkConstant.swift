//
//  NetworkConstant.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 11.06.2023.
//

import Foundation

class NetworkConstant {
    
    public var shared: NetworkConstant = NetworkConstant()
    
    private init() {}
    
    static let headers = [
           "content-type": "application/json",
           "X-RapidAPI-Key": "fe83b38e34mshc8c70c0d52b8a61p1ac627jsnbdb546853370",
           "X-RapidAPI-Host": "microsoft-translator-text.p.rapidapi.com"
       ]
    
    static let postMethod = "POST"
}
