//
//  GoogleAuthToken.swift
//  videoApp
//
//  Created by LeeJongMin on 2018/4/15.
//  Copyright © 2018 flymax. All rights reserved.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import MobileCoreServices

class GoogleAuthTokenVC : UIViewController,  GIDSignInDelegate, GIDSignInUIDelegate {
    let output = UITextView()
    
    let service : GTLRYouTubeService = GTLRYouTubeService()
    var uploadTitleField = "Moview Filter Video"
    var uploadPathField = ""
    var uploadFileTicket: GTLRServiceTicket?
    
    var uploadLocationURL : URL? = nil
    var progressbar : UIProgressView!
    
    public func getYoutubeToken(){
        if let user = GIDSignIn.sharedInstance().currentUser{
            self.processVideo()
        }
        else {
        GIDSignIn.sharedInstance().clientID = "828565369150-1dlvq70b092j2m1h6p9digmosa17p84v.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().serverClientID = "828565369150-!!!~~~!!!apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = ["email","profile", "https://www.googleapis.com/auth/youtube.upload",kGTLRAuthScopeYouTube,kGTLRAuthScopeYouTubeForceSsl, kGTLRAuthScopeYouTubeUpload,kGTLRAuthScopeYouTubeYoutubepartner]
        GIDSignIn.sharedInstance().serverClientID = ""
        
//        //GIDSignIn.sharedInstance().scopes = ["https://youtube.google.com/"]
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signIn()
        }
    }
    func processVideo(){
        //TODO upload video to youtube
        if let user = GIDSignIn.sharedInstance().currentUser {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
        }
        uploadVideoFile()
    }
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            
//            self.service.authorizer = user.authentication.fetcherAuthorizer()
            self.processVideo()
            //            let userInfo = UserInfo()
            //            userInfo.firstName = user.profile.givenName
            //            userInfo.lastName = user.profile.familyName
            //            userInfo.email = user.profile.email
            //            userInfo.source = "google"
            //            userInfo.socialId = user.userID
            //            userInfo.tokenId = user.authentication.idToken
//            ServerAPI.updateEmailToken(token: Utils.string(user.serverAuthCode), email: Utils.string(user.profile.email), success: { (op, resObj) in
//                if let status = resObj?["status"] as? String , status == "Success"{
//                    Utils.msgBox(nil,message: NSLocalizedString("M_ImportReservationMsg", comment: "")) //"Your reservation will import automatically soon.")
//                }
//                else{
//                    Utils.msgBox(nil,message: Utils.string(resObj?["message"]))
//                }
//            })
            
        }
        
    }
    // MARK: - Upload
    func uploadVideoFile() {
        // Collect the metadata for the upload from the user interface.
        // Status.
        let status = GTLRYouTube_VideoStatus()
        status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Private//uploadPrivacyPopup.titleOfSelectedItem
        status.privacyStatus = kGTLRYouTube_ChannelStatus_PrivacyStatus_Public
        // Snippet.
        let snippet = GTLRYouTube_VideoSnippet()
        snippet.title = "\(uploadTitleField)"
        let desc = "This video is uploaded from moview. https://moview.app"
        if (desc.count ?? 0) > 0 {
            snippet.descriptionProperty = desc
        }
        let tagsStr = ""
        if (tagsStr.count ?? 0) > 0 {
            snippet.tags = tagsStr.components(separatedBy: ",")
        }
        
        let video = GTLRYouTube_Video()
        video.status = status
        video.snippet = snippet
        do {
        let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
        let fileURL = URL(string:"save.mp4", relativeTo:documentsDir)!
        
        uploadPathField = fileURL.path
        }catch{}
        self.displayProgressBarWithProgress(0, sender: self)
        uploadVideo(withVideoObject: video, resumeUploadLocationURL: nil)
    }
    func restartUpload() {
        // Restart a stopped upload, using the location URL from the previous
        // upload attempt
        if uploadLocationURL == nil {
            return
        }
        // Since we are restarting an upload, we do not need to add metadata to the
        // video object.
        let video = GTLRYouTube_Video()
        uploadVideo(withVideoObject: video, resumeUploadLocationURL: uploadLocationURL)
    }
    func uploadVideo(withVideoObject video: GTLRYouTube_Video, resumeUploadLocationURL locationURL: URL?) {
        let fileToUploadURL = URL(fileURLWithPath: "\(uploadPathField)")
        var fileError: Error?
        if !(try! fileToUploadURL.checkPromisedItemIsReachable()) {
            return
        }
        // Get a file handle for the upload data.
        let filename: String? = fileToUploadURL.lastPathComponent
        let mimeType: String = self.mimeType(forFilename: filename!, defaultMIMEType: "video/mp4")
        let uploadParameters = GTLRUploadParameters(fileURL: fileToUploadURL, mimeType: mimeType)
        uploadParameters.uploadLocationURL = locationURL
        
        
        
        let query = GTLRYouTubeQuery_VideosInsert.query(withObject: video, part: "snippet,status", uploadParameters: uploadParameters)
        
        
        
        query.executionParameters.uploadProgressBlock = {(_ ticket: GTLRServiceTicket, _ numberOfBytesRead: UInt64, _ dataLength: UInt64) -> Void in
            print ("total bytes = \(Double(dataLength))")
            print ("uploaded bytes = \(Double(numberOfBytesRead))")
            self.progressbar.progress = Float(Double(numberOfBytesRead)/Double(dataLength))
        }
        
        uploadFileTicket = service.executeQuery(query,
                                                delegate: self,
                                                didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        
    }
    func mimeType(forFilename filename: String, defaultMIMEType defaultType: String) -> String {
        let result: String = defaultType
        return result
    }
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_Video,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "오류!", message: error.localizedDescription)
            return
        }
        self.hideProgressBar(self, completion: {
            self.showAlert(title: "업로드 결과", message: "Uploaded file \(String(describing: response.snippet!.title!))")
        })
        
        
        
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: {
            //
            if let vc = UIApplication.topViewController() as? AlertViewController{
                vc.restartFilterFn?()
            }
            UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
        })
    }
    
    //        MARK:- Image picker delegate methods
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
//    {
//        self.uploadPathField = (info[UIImagePickerControllerMediaURL] as! URL).path
//        self.dismiss(animated: true) {
//            self.displayProgressBarWithProgress(0, sender: self)
//            self.uploadVideoFile()
//
//        }
//
//    }
    //        MARK:- Hide Show progressbar methhods
    func displayProgressBarWithProgress(_ progres:Float,sender:UIViewController) -> (UIProgressView) {
        //create an alert controller
        let alertController = UIAlertController(title: "업로드 중...", message: "\n"+" 업로드 중입니다...", preferredStyle: UIAlertControllerStyle.alert)
        
        self.progressbar = UIProgressView.init(progressViewStyle: .default)
        self.progressbar.center = CGPoint(x: 135.0, y: 100)
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150)
        alertController.view.addConstraint(height);
        self.progressbar.progress = progres
        self.progressbar.tintColor =  UIColor.init(red: 2/255.0, green: 133/255.0, blue: 198/255.0, alpha: 1.0)
        alertController.view.addSubview(self.progressbar)
        sender.present(alertController, animated: false, completion: nil)
        return self.progressbar;
    }
    
    func hideProgressBar(_ sender:UIViewController, completion : @escaping ()->()) {
        sender.dismiss(animated: true, completion: completion)
    }
}
