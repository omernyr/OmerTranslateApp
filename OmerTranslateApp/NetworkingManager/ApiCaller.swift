//
//  ApiCaller.swift
//  OmerTranslateApp
//
//  Created by macbook pro on 11.06.2023.
//

import Foundation


class APICaller {
    
    func translateText(text: String, fromLanguage: String, targetLanguage: String, completion: @escaping (String?, Error?) -> Void) {
        let headers = [
            "content-type": "application/json",
            "X-RapidAPI-Key": "fe83b38e34mshc8c70c0d52b8a61p1ac627jsnbdb546853370",
            "X-RapidAPI-Host": "microsoft-translator-text.p.rapidapi.com"
        ]
        
        let parameters = [["Text": text]]
        
        guard let postData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completion(nil, NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create request body."]))
            return
        }
        
        let urlString = "https://microsoft-translator-text.p.rapidapi.com/translate?to%5B0%5D=\(targetLanguage)&api-version=3.0&from=\(fromLanguage)&profanityAction=NoAction&textType=plain"
                        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request URL."]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received."]))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                
                if let translations = json?.first?["translations"] as? [[String: Any]], let translatedText = translations.first?["text"] as? String {
                    completion(translatedText, nil)
                } else {
                    completion(nil, NSError(domain: "TranslationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Translation not found in response."]))
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
}
