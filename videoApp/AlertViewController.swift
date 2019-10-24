//
//  AlertViewController.swift
//  videoApp
//
//  Created by LeeJongMin on 2018/4/29.
//  Copyright © 2018 flymax. All rights reserved.
//

import UIKit
import Photos
//import AssetsLibrary
class AlertViewController: GoogleAuthTokenVC {
    var restartFilterFn : (()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func shareToInsta(_ sender: Any) {
        let title = "title"
        do {
            let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            //        let fileURL1 = URL(string:"save.mp4", relativeTo:documentsDir)!
            let fileURL = URL(string:documentsDir.absoluteString + "save.mp4")!
            var localId : String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                localId = request?.placeholderForCreatedAsset?.localIdentifier
            }) { saved, error in
                if let localId = localId, saved {
                    let instagramString = "instagram://library?AssetPath=\(localId)&InstagramCaption=\(title)"
                    
                    let instagramURL = NSURL(string: instagramString)
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(instagramURL! as URL)
                        {
                            UIApplication.shared.openURL(instagramURL! as URL)
                            self.dismiss(animated: true, completion: {
                                self.restartFilterFn?()
                            })
                        }
                        else
                        {
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id389801252"),
                                UIApplication.shared.canOpenURL(url){
                                self.dismiss(animated: true, completion: {
                                    self.restartFilterFn?()
                                })
                                UIApplication.shared.openURL(url)
                            }
                            //print("Instagram app not installed.")
                        }
                    }
//                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
//                    let asset = result.object(at: 0)
                }
            }
        }catch{

        }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main" , bundle: nil)
//        let newVC = storyBoard.instantiateViewController(withIdentifier: "InstagramViewController")
//        newVC.modalTransitionStyle = .crossDissolve
//        let instaVC = newVC.childViewControllers.first as! InstagramViewController
//        instaVC.callback = { username in
//        }
//        self.present(newVC, animated: true, completion: nil)
    }
    @IBAction func shareToYoutube(_ sender: Any) {
        self.getYoutubeToken()
    }
    func postVideoToYouTube(token: String, callback: (Bool) -> Void) throws{
        
        let headers = ["Authorization": "Bearer \(token)"]

        let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
        let fileURL = URL(string:documentsDir.absoluteString + "save.mp4")!

//        let videodata: NSData = NSData.dataWithContentsOfMappedFile(documentsDir.absoluteString + "save.mp4")! as! NSData
        let videodata = try Data.init(contentsOf: fileURL)
//        upload(
//            .POST,
//            "https://www.googleapis.com/upload/youtube/v3/videos?part=id",
//            headers: headers,
//            multipartFormData: { multipartFormData in
//                multipartFormData.appendBodyPart(data: videodata, name: "video", fileName: "video.mp4", mimeType: "application/octet-stream")
//        },
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .Success(let upload, _, _):
//                    upload.responseJSON { request, response, error in
//                        print(response)
//                        callback(true)
//                    }
//                case .Failure(_):
//                    callback(false)
//                }
//        })
    }
    @IBAction func SaveToPhotoLibrary(_ sender: Any) {
        do {
        let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
//        let fileURL1 = URL(string:"save.mp4", relativeTo:documentsDir)!
        let fileURL = URL(string:documentsDir.absoluteString + "save.mp4")!
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: {
                        self.restartFilterFn?()
                        
                    })
                })
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        }catch{
            
        }
    }
    @IBAction func onClickDismiss(_ sender: Any) {
        Utils.msgBoxYesNo(self, title: "메시지", message: "정말 취소하시겠습니까?", handler1: { _ in
            self.dismiss(animated: true, completion: {
                self.restartFilterFn?()
            })
        }, handler2: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
