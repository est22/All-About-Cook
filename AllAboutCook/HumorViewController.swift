//
//  HumorViewController.swift
//  AllAboutCook
//
//  Created by Lia An on 9/9/24.
//

import UIKit

class HumorViewController:  UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var humorText: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        randomHumor()
    }
    
    
    func randomHumor() {
        let endPoint = "https://api.spoonacular.com/food/jokes/random"
        guard let strURL = endPoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: endPoint) else { return }
        var request = URLRequest(url: url)
        
        // header 교체
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // 세션 연결  - Singleton Pattern
        let session = URLSession.shared
        // task 생성
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            guard let data else { return } // 데이터 언랩핑 -> guard-let으로 해라.(코드블럭 안으로 안들어가도 됨)
            // Data 직렬화
            do {
                guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                else { return }
                let text = root["text"] as? String
                
                
                DispatchQueue.main.async {
                    self.textView.text = text
                    
                }
                
            } catch {
                print("JSON Parsing Error Occured")
            }
        }.resume()
    }
    
    
    
}
