//
//  Paid.swift
//  videoApp
//
//  Created by LeeJongMin on 2018/4/29.
//  Copyright © 2018 flymax. All rights reserved.
//

import Foundation

import StoreKit


public var paidSubscription : PaidSubscription?
public var activeSubscriptions : [PaidSubscription]?
class PurchaseVC : UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    /* Variables */
    static let horrorFilter = "moview.Horror"
    static let springFilter = "moview.Spring"
    static let romanceFilter = "moview.Romance"
    static let lifeFilter = "moview.Life"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        fetchAvailableProducts() // if neccessary, have to call this function.
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        nonConsumablePurchaseMade = true
//        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
        if queue.transactions.count == 0 {
            Utils.msgBox(self, message: "There is no purchase!")
        }
        else {
            //queue.transactions[0].transactionIdentifier
            for item in queue.transactions {
                if item.transactionIdentifier == PurchaseVC.springFilter {
                    // add Spring Filter
                    
                }
                else if item.transactionIdentifier == PurchaseVC.horrorFilter {
                    // add Horror Filter
                }
                else if item.transactionIdentifier == PurchaseVC.romanceFilter {
                    // add Horror Filter
                }
                else if item.transactionIdentifier == PurchaseVC.lifeFilter {
                    // add Horror Filter
                }
            }
            Utils.msgBox(self, message: "You've successfully restored your purchase!")
        }
        
    }
    func fetchAvailableProducts()  {
        let productIdentifiers = Set([PurchaseVC.horrorFilter, PurchaseVC.lifeFilter, PurchaseVC.romanceFilter, PurchaseVC.springFilter])
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    func iapProductsDidLoad(){
        uploadReceipt()
    }
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        Log.info("products: \(response.products.count)")
        if (response.products.count > 0) {
            iapProducts = response.products
            self.iapProductsDidLoad()
            //            // 1st IAP Product (Consumable) ------------------------------------
            //            let firstProduct = response.products[0] as SKProduct
            //
            //            // Get its price from iTunes Connect
            //            let numberFormatter = NumberFormatter()
            //            numberFormatter.formatterBehavior = .behavior10_4
            //            numberFormatter.numberStyle = .currency
            //            numberFormatter.locale = firstProduct.priceLocale
            //            let price1Str = numberFormatter.string(from: firstProduct.price)
        }
    }
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            
            Log.info("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            //            UIAlertView(title: "IAP Tutorial",
            //                        message: "Purchases are disabled in your device!",
            //                        delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    func purchaseSuccess(_ id: String){
        
    }
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    showToast("Purchase succeed.")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    if productID ==  PurchaseVC.horrorFilter{
                        
                    } else if productID == PurchaseVC.springFilter {
                        
                    }
                    self.purchaseSuccess(productID)
                    
                    //                   receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                    //                   receipt = [NSData dataWithContentsOfURL:receiptURL];
                    uploadReceipt {(success) in
                        if let paid = paidSubscription{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                            let expireDate = dateFormatter.string(from: paid.expiresDate)
//                            let purchaseDate = dateFormatter.string(from: paid.purchaseDate)
//                            HttpClient.setPurchaseSave(userNo: PrefMain.getUserNo(), orderId: trans.transactionIdentifier!, packageName: Bundle.main.bundleIdentifier!, productId: paid.productId, purchaseTime: purchaseDate, purchaseState: 1, developerPayload: "iOS", purchaseToken: expireDate)
                        }
                    }
                    break
                case .failed:
                    //showToast("Purchase failed.")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    showToast("Purchase restored.")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default: break
                }}}
    }
    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            upload(receipt: receiptData) { [weak self] (result) in
                //                guard let strongSelf = self else { return }
                switch result {
                case .success(let result):
                    Log.info("SessionID:\(result.id)")
                    Log.info("currentSubscription:\(result.currentSubscription)")
                    paidSubscription = result.currentSubscription
                    activeSubscriptions = result.paidSubscriptions.filter { $0.isActive }
                    //                    strongSelf.currentSessionId = result.sessionId
                    //                    strongSelf.currentSubscription = result.currentSubscription
                    completion?(true)
                case .failure(let error):
                    Log.error("🚫 Receipt Upload Failed: \(error)")
                    completion?(false)
                }
            }
        }
        else{
            completion?(false)
        }
    }
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            Log.error("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let receiptURL = Bundle.main.appStoreReceiptURL
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": "5e1fc460dafb48bb9ee98671cf3a1a2e"
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let appServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
        
        let url = URL(string: "https://\(appServer).itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            
            Log.info(responseData)
            if let error = error {
                completion(.failure(error))
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                //print(json)
                let session = SubscriptionSession(receiptData: data, parsedReceipt: json)
                //self.sessions[session.id] = session
//                let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
//                completion(.success(result))
                completion(.success(session))
            }
        }
        
        task.resume()
    }
}
