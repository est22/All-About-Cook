//
//  WebViewController.swift
//  AllAboutCook
//
//  Created by Lia An on 9/9/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var strURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let strURL, let url = URL(string: strURL)
        else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)

    }
    

    

}



