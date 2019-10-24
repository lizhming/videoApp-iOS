//
//  InstagramLoginViewController.swift
//  boundaryApp
//
//  Created by LeeJongMin on 2018/4/16.
//  Copyright © 2018 flymax. All rights reserved.
//

import UIKit
import WebKit

struct INSTAGRAM_IDS {
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
    static let INSTAGRAM_CLIENT_ID  = "74fc9f96434442cdb18354a863423d7b"
    static let INSTAGRAM_CLIENTSERCRET = "8dd4a51acaba4be4bf30766c9b9b5043"
    static let INSTAGRAM_REDIRECT_URI = "http://13.125.72.245/"
    static let INSTAGRAM_ACCESS_TOKEN =  "access_token"
    static let INSTAGRAM_SCOPE = "basic"
}

class InstagramViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    var loginWebView: WKWebView!
    
    @IBOutlet weak var vwParent: UIView!
    var callback: ((String)->Void)?
    func initWebView(){
        let webConfiguration = WKWebViewConfiguration()
        
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        webConfiguration.userContentController = wkUController
        
        loginWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        loginWebView.uiDelegate = self
        loginWebView.navigationDelegate = self
        loginWebView.translatesAutoresizingMaskIntoConstraints = false
        vwParent.addSubview(loginWebView)
        let constraint1 = NSLayoutConstraint.init(item: loginWebView, attribute: .leading, relatedBy: .equal, toItem: vwParent, attribute: .leading, multiplier: 1, constant: 0)
        let constraint2 = NSLayoutConstraint.init(item: loginWebView, attribute: .top, relatedBy: .equal, toItem: vwParent, attribute: .top, multiplier: 1, constant: 0)
        let constraint3 = NSLayoutConstraint.init(item: loginWebView, attribute: .trailing, relatedBy: .equal, toItem: vwParent, attribute: .trailing, multiplier: 1, constant: 0)
        let constraint4 = NSLayoutConstraint.init(item: loginWebView, attribute: .bottom, relatedBy: .equal, toItem: vwParent, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([constraint1, constraint2, constraint3, constraint4])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove all cache
        URLCache.shared.removeAllCachedResponses()
        
        // Delete any associated cookies
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        initWebView()
        unSignedRequest()
        
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_btn")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onClickLeftMenu))
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title:"Back", style: .plain, target: self, action: #selector(onClickLeftMenu))
        //        navigationItem.titleView = UIImageView(image: UIImage(named: "b_symbol_nav")!)
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(named:"clear"), for: .default)
//        let _ = navigationController?.navigationBar.setBottomBorderColor(color: .black, height: 0.5)
    }
    @objc func onClickLeftMenu(_ sender: Any){
        //        IQKeyboardManager.sharedManager().enable = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        let urlLogout = URLRequest.init(url: URL(string:"https://instagram.com/accounts/logout/")!)
        //        loginWebView.load(urlLogout)
        loginWebView.load(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            if let range = requestURLString.range(of: "#access_token=") {
                handleAuth(authToken: requestURLString.substring(from: range.upperBound))
                return false;
            }
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        print("Instagram authentication token ==", authToken)
        let url = "https://api.instagram.com/v1/users/self/?access_token=\(authToken)"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let posts = json["data"] as? [String: Any] ?? [:]
                self.callback?("ok")
//                self.callback?(Utils.string(posts["username"]))
                print(posts)
                
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if checkRequestForCallbackURL(request: navigationAction.request) {
            decisionHandler(.allow)
        }
        else {
            self.dismiss(animated: false, completion: nil)
            decisionHandler(.cancel)
        }
    }
    
}

