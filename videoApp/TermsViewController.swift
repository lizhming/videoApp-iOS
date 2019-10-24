//
//  TermsViewController.swift
//  boundaryApp
//
//  Created by LeeJongMin on 26/03/2018.
//  Copyright © 2018 flymax. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController , WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        //        let wkWebConfig = WKWebViewConfiguration()
        webConfiguration.userContentController = wkUController
        //        let yourWebView = WKWebView(frame: self.view.bounds, configuration: wkWebConfig)
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    var urlStr = "http://13.125.72.245/terms/terms_3.php"
    var titleStr = "이용약관"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_chevron_left_24px")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.onClickBack(_:)))
        //        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.title = titleStr
        
        
        let url = URL(string: urlStr)
        webView.load(URLRequest(url: url!))
    }
    @objc func onClickMenu(_ sender: Any){
        //Menu
    }
    @IBAction func onClickBack(_ sender: AnyObject) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func onClickDeny(_ sender: Any) {
        exit(0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
