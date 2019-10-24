//
//  ContentsViewController.swift
//  videoApp
//
//  Created by LeeJongMin on 2018/4/29.
//  Copyright © 2018 flymax. All rights reserved.
//

import UIKit
import StoreKit

class ContentsViewController: PurchaseVC {
    @IBOutlet weak var springView: UIView!
    @IBOutlet weak var horrorView: UIView!
    @IBOutlet weak var lifeView: UIView!
    @IBOutlet weak var romanceView: UIView!
    
    @IBOutlet weak var marketRomanceView: UIView!
    @IBOutlet weak var marketSpringView: UIView!
    @IBOutlet weak var marketHorrorView: UIView!
    @IBOutlet weak var marketLifeView: UIView!
    @IBOutlet weak var lblPriceSpring: UILabel!
    @IBOutlet weak var lblPriceHorror: UILabel!
    @IBOutlet weak var lblPriceRomance: UILabel!
    @IBOutlet weak var lblPriceLife: UILabel!
    
    @IBOutlet weak var lblFilterComment: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.titleView = UIImageView(image: UIImage(named: "contents")!)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_chevron_left_24px")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onClickBack))
        fetchAvailableProducts()
        
        let purchaseSpring = UserDefaults.standard.bool(forKey: PurchaseVC.springFilter)
        let purchaseRomance = UserDefaults.standard.bool(forKey: PurchaseVC.romanceFilter)
        let purchaseHorror = UserDefaults.standard.bool(forKey: PurchaseVC.horrorFilter)
        let purchaseLife = UserDefaults.standard.bool(forKey: PurchaseVC.lifeFilter)
        if purchaseSpring {
            springView.isHidden = false
            marketSpringView.isHidden = true
        }
        if purchaseHorror {
            horrorView.isHidden = false
            marketHorrorView.isHidden = true
        }
        if purchaseRomance {
            romanceView.isHidden = false
            marketRomanceView.isHidden = true
        }
        if purchaseLife {
            lifeView.isHidden = false
            marketLifeView.isHidden = true
        }
    }
    
    override func iapProductsDidLoad(){
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = iapProducts[0].priceLocale
        lblPriceSpring.text = numberFormatter.string(from: iapProducts[0].price)
        lblPriceHorror.text = numberFormatter.string(from: iapProducts[1].price)
        lblPriceRomance.text = numberFormatter.string(from: iapProducts[2].price)
        lblPriceLife.text = numberFormatter.string(from: iapProducts[3].price)
        uploadReceipt()
    }
    override func purchaseSuccess(_ id: String) {
        switch  id {
        case PurchaseVC.horrorFilter:
            
            UserDefaults.standard.set(true, forKey: PurchaseVC.horrorFilter)
        case PurchaseVC.springFilter:
            
            UserDefaults.standard.set(true, forKey: PurchaseVC.springFilter)
        case PurchaseVC.romanceFilter:
            
            UserDefaults.standard.set(true, forKey: PurchaseVC.romanceFilter)
        case PurchaseVC.lifeFilter:
            
            UserDefaults.standard.set(true, forKey: PurchaseVC.lifeFilter)
        default:
            break
        }
    }
    @objc func onClickBack(_ sender: Any){
        self.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickRestore(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    @IBAction func onClickLife(_ sender: Any) {
        guard iapProducts[1] != nil else {
            return
        }
        purchaseMyProduct(product: iapProducts[1])
    }
    @IBAction func onClickSpring(_ sender: Any) {
        guard iapProducts[3] != nil else {
            return
        }
        purchaseMyProduct(product: iapProducts[3])
        
    }
    @IBAction func onClickHorror(_ sender: Any) {
        guard iapProducts[0] != nil else {
            return
        }
        
        purchaseMyProduct(product: iapProducts[0])
    }
    
    @IBAction func onClickRomance(_ sender: Any) {
        guard iapProducts[2] != nil else {
            return
        }
        
        purchaseMyProduct(product: iapProducts[2])
    }
    @IBAction func onClickPrivacyPolicy(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main" , bundle: nil)
        let newVC = storyBoard.instantiateViewController(withIdentifier: "TermsNavViewController") as! UINavigationController
        let termsVC = newVC.childViewControllers.first as! TermsViewController
        termsVC.titleStr = "개인정보처리방침"
        termsVC.urlStr = "http://13.125.72.245/terms/moview_privacy.php"
        self.present(newVC, animated:  true, completion: nil)
    }
    @IBAction func onClickTermsOfUse(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main" , bundle: nil)
        let newVC = storyBoard.instantiateViewController(withIdentifier: "TermsNavViewController") as! UINavigationController
        let termsVC = newVC.childViewControllers.first as! TermsViewController
        termsVC.titleStr = "이용약관"
        termsVC.urlStr = "http://13.125.72.245/terms/moview_terms.php"
        self.present(newVC, animated:  true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
