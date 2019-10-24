//
//  Utils.swift
//  Moview
//
//  Created by LeeJongMin on 02/02/2018.
//  Copyright © 2018 flymax. All rights reserved.
//

import Foundation
import UIKit
enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}
class Utils{
    class func updateApp(){
        
        if (UIApplication.shared.canOpenURL(URL(string:"itms-apps://itunes.apple.com/app/id1360966658")!)) {
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1360966658")!)
            //Moview
        }
    }
    class func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        Log.debug(currentVersion)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                Log.debug(json as Any)
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    class func systemFont(attributedText: NSAttributedString, size: Float = 17)-> NSAttributedString?  {
        let newAttributedString = NSMutableAttributedString(attributedString: attributedText)
        
        // Enumerate through all the font ranges
        newAttributedString.enumerateAttribute(NSAttributedStringKey.font, in: NSMakeRange(0, newAttributedString.length), options: []) {
            value, range, stop in
            guard let currentFont = value as? UIFont else {
                return
            }
            
            // An NSFontDescriptor describes the attributes of a font: family name, face name, point size, etc.
            // Here we describe the replacement font as coming from the "Hoefler Text" family
            //                    let fontDescriptor = currentFont.fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.family: UIFont.boldSystemFont(ofSize: 17).familyName])
            //
            if (currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)){
                newAttributedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(size))], range: range)
            }
            else {
                newAttributedString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(size))], range: range)
            }
            
        }
        
        return newAttributedString
    }
    class func systemFontKeepSize(attributedText: NSAttributedString)-> NSAttributedString?  {
        let newAttributedString = NSMutableAttributedString(attributedString: attributedText)
        
        // Enumerate through all the font ranges
        newAttributedString.enumerateAttribute(NSAttributedStringKey.font, in: NSMakeRange(0, newAttributedString.length), options: []) {
            value, range, stop in
            guard let currentFont = value as? UIFont else {
                return
            }
            
            // An NSFontDescriptor describes the attributes of a font: family name, face name, point size, etc.
            // Here we describe the replacement font as coming from the "Hoefler Text" family
            //                    let fontDescriptor = currentFont.fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.family: UIFont.boldSystemFont(ofSize: 17).familyName])
            //
            if (currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)){
                newAttributedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(currentFont.pointSize))], range: range)
            }
            else {
                newAttributedString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(currentFont.pointSize))], range: range)
            }
            
        }
        
        return newAttributedString
    }
    class func stringFromHtml(_ string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf16, allowLossyConversion: false)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
            //catch
        }
        return NSAttributedString()
    }
    class func getCurrency(_ money: String, rate: String) -> String{
        if let rate = Double(rate), let money = Double(money){
            return format(number:String(rate * money))
        }
        return "0"
    }
    class func format(number: Any?)->String{// 1234.003 -> 1,234.00
        let fmt = NumberFormatter()
        fmt.usesGroupingSeparator = true
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        fmt.generatesDecimalNumbers = true
        if let val = Double(Utils.string(number)){
            return fmt.string(from: NSNumber(value: val))!
        }
        return fmt.string(from: NSNumber(value: 0))!
    }
    class func to(number: String)->String {// 1,234.00 -> 1234.00
        let fmt = NumberFormatter()
        fmt.usesGroupingSeparator = true
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        fmt.generatesDecimalNumbers = true
        if let val = fmt.number(from: number)?.doubleValue{
            return String(val)
        }
        return "0"
    }
    class func callNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber.trimmingCharacters(in: .whitespaces).components(separatedBy: " ").joined(separator: ""))") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL)
                }
            }
        }
    }
    
    class func getImageUrl(_ strUrl: String!)-> UIImage?{ //https://s3.eu-central-1.amazonaws.com/crl-project/Airline/
        let url = URL(string: strUrl)!
        let data = try? Data(contentsOf: url)
        
        if let imageData = data {
            
            let image = UIImage(data: imageData)
            return image
        }
        return nil
    }
    class func getImage(_ strUrl: String!)-> UIImage?{
        //        return getImageUrl(strUrl)
        
        let imgUrl = downloadContents(strUrl)
        if let url = imgUrl{
            let data = try? Data(contentsOf: url)
            
            if let imageData = data {
                
                let image = UIImage(data: imageData)
                return image
            }
        }
        return nil
    }
    class func downloadContents(_ strUrl: String, path: String = "") -> URL?{
        if let fileUrl = URL(string: strUrl){
            let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            do {
                try FileManager.default.createDirectory(atPath: documentDirectoryUrl.appendingPathComponent(path).absoluteString, withIntermediateDirectories: false, attributes: nil)
            } catch let error{
                Log.error(error.localizedDescription);
                
            }
            
            //            let destinationUrl = documentDirectoryUrl.appendingPathComponent(path+"/"+fileUrl.lastPathComponent)
            let destinationUrl = documentDirectoryUrl.appendingPathComponent(path+"/\(strUrl.hashValue).tmp")
            if FileManager.default.fileExists(atPath: destinationUrl.path){
                return destinationUrl;
            }
            else{
                do{
                    let url = URL(string: strUrl)!
                    let data = try? Data(contentsOf: url)
                    try? data?.write(to: destinationUrl)
                    return destinationUrl
                } catch{
                    //catch
                }
            }
        }
        
        return nil
    }
    class func string(_ any: Any?, defaultStr: String = "") -> String{
        if let val = any as? Int{
            return "\(val)"
        }
        else if let fval = any as? Float{
            return "\(fval)"
        }
        else if let dval = any as? Double{
            return "\(dval)"
        }
        else if let sval = any as? String{
            return sval
        }
        return defaultStr
    }
    class func removeSpace(_ str: String) -> String {
        return str.components(separatedBy: .whitespaces).joined()
    }
    class func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    /*
     Minimum 8 characters at least 1 Alphabet and 1 Number:
     
     "^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$"
     Minimum 8 characters at least 1 Alphabet, 1 Number and 1 Special Character:
     
     "^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,}$"
     Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet and 1 Number:
     
     "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$"
     Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
     
     "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[d$@$!%*?&#])[A-Za-z\dd$@$!%*?&#]{8,}"
     Minimum 8 and Maximum 10 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
     
     "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&#])[A-Za-z\d$@$!%*?&#]{8,10}"
     */
    class func isValidPasswordOneNumberOneSpec(_ testStr:String) -> Bool {
        let passRegEx =  "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let test = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return test.evaluate(with: testStr)
    }
    class func isValidExceptChar(_ testStr:String) -> Bool {
        let passRegEx = "^(?=.*[<>()#'/|])[A-Za-z\\d$@$!%*#?&]$"
        let test = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return !test.evaluate(with: testStr)
    }
    class func msgBox(_ viewController:UIViewController?, title:String = "Message", message:String, handler: ((UIAlertAction) -> Void )? = nil){
        var viewCtl = viewController
        if viewCtl == nil {
            viewCtl = UIApplication.topViewController()
        }
        DispatchQueue.main.async(execute: {
            let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: handler)
            dialogMessage.addAction(defaultAction)
            viewCtl?.present(dialogMessage, animated: false, completion: nil)
        })
    }
    class func msgBoxYesNo(_ viewController:UIViewController, title:String = "Message", message:String, handler1: ((UIAlertAction) -> Void )? = nil, handler2: ((UIAlertAction) -> Void)? = nil){
        DispatchQueue.main.async(execute: {
            let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "취소", style: .default, handler: handler2)
            dialogMessage.addAction(defaultAction)
            let default1Action = UIAlertAction(title: "확인", style: .default, handler: handler1)
            dialogMessage.addAction(default1Action)
            viewController.present(dialogMessage, animated: false, completion: nil)
        })
    }
    class func localToUTC(date:String, formatter: String = "yyyy-MM-dd HH:mm:ss", toFormatter: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateFormatter.dateFormat = toFormatter
        
        return dateFormatter.string(from: dt!)
    }
    
    class func UTCToLocal(date:String, formatter: String = "yyyy-MM-dd HH:mm:ss", toFormatter: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormatter
        
        return dateFormatter.string(from: dt!)
    }
    
    class func json(from object: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}
extension Date {
    func string(with format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue:0)) else {
            return nil
        }
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    func contains(find: String) -> Bool {
        return self.range(of: find) != nil
    }
    func contains(findIgnoringCase: String) -> Bool{
        return self.range(of: findIgnoringCase, options: .caseInsensitive) != nil
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        else if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


