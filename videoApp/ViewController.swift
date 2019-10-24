//
//  ViewController.swift
//  videoApp
//
//  Created by LeeJongMin on 14/03/2018.
//  Copyright © 2018 flymax. All rights reserved.
//

import UIKit
import GPUImage2
import AVFoundation
import Firebase
//import GoogleMobileAds

import Appirater
class ViewController: PurchaseVC, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var renderView: RenderView!
    var camera:Camera!
    var filter:SaturationAdjustment!
    var isRecording = false
    var movieOutput:MovieOutput? = nil
    
    var movie:MovieInput!
    var filter1:Pixellate!
    var lastFilter : BasicOperation?
    var blendFilter : BasicOperation = OverlayBlend()
    
    @IBOutlet weak var btnMode: UIButton!
    @IBOutlet weak var bottomLabel: NSLayoutConstraint!
    @IBOutlet weak var labelMode: UIImageView!
    @IBOutlet weak var viewMenu: UIView!
    var currentMode : Int = 0
    // 0: default
    // 1: Romance
    // 2: Life
    // 3: Spring
    // 4: Horror
    
    @IBOutlet weak var viewBanner: UIView!
    
    @IBAction func onClickItem(_ sender: UIButton) {
        if isRecording {
            return
        }
        
        currentMode = sender.tag
        viewMenu.isHidden = true
        
        switch currentMode {
        case 0:
            btnMode.setImage(UIImage(named: "my_contents_btn.png"), for: .normal)
            btnMode.contentVerticalAlignment = .center
            labelMode.isHidden = true
        case 1:
            btnMode.setImage(UIImage(named: "romance_icon.png"), for: .normal)
            btnMode.contentVerticalAlignment = .top
            labelMode.isHidden = false
            labelMode.image = UIImage(named: "Romance.png")
            bottomLabel.constant = 0
        case 2:
            btnMode.setImage(UIImage(named: "life_icon.png"), for: .normal)
            btnMode.contentVerticalAlignment = .top
            labelMode.isHidden = false
            labelMode.image = UIImage(named: "life.png")
            bottomLabel.constant = 5
        case 3:
            btnMode.setImage(UIImage(named: "spring_icon.png"), for: .normal)
            btnMode.contentVerticalAlignment = .top
            labelMode.isHidden = false
            labelMode.image = UIImage(named: "Spring.png")
            bottomLabel.constant = 0
        default:
            btnMode.setImage(UIImage(named: "horror_icon.png"), for: .normal)
            btnMode.contentVerticalAlignment = .top
            labelMode.isHidden = false
            labelMode.image = UIImage(named: "Horror.png")
            bottomLabel.constant = 2
        }
        setFilter()
    }
    var cameraLocation : PhysicalCameraLocation = .backFacing
    let videoSize = CGSize(width: 1920, height: 1080)
    @IBAction func onClickChange(_ sender: Any) {
        if isRecording {
            return
        }
        
        if camera.location == .frontFacing {
            //camera.location = .backFacing
        }
        else {
            //camera.location = .frontFacing
            
        }
        var size : CGSize
        if cameraLocation == .frontFacing{
            cameraLocation = .backFacing
            size = getCaptureResolution(pos: .back)
            
//            AVCaptureConnection.videoMirrored = false
        }
        else {
            cameraLocation = .frontFacing
            size = getCaptureResolution(pos: .front)
//            AVCaptureConnection.videoMirrored = true
        }
        do {
            camera.removeAllTargets()
            camera.stopCapture()
            
            camera = try Camera(sessionPreset:AVCaptureSession.Preset.high, location: cameraLocation)
            
            cameraCrop.cropSizeInPixels = Size.init(width: Float(size.width), height: Float(size.width))
            cameraCrop.locationOfCropInPixels = Position.init(0, Float((size.height - size.width) / 2)) // center?
            cameraCrop.locationOfCropInPixels = Position.init(0, 0) // center?
            crop1.cropSizeInPixels = Size.init(width: Float(size.width), height: Float(size.width))
            crop1.locationOfCropInPixels = Position.init(Float((videoSize.width - size.width) / 2), Float((videoSize.height - size.width) / 2)) // center?
//            crop1.locationOfCropInPixels = Position.init(500, 0) // center?
            crop2.cropSizeInPixels = Size.init(width: Float(size.width), height: Float(size.width))
            crop2.locationOfCropInPixels = Position.init(0, Float((size.height - size.width) / 2)) // center?
            crop2.locationOfCropInPixels = Position.init(0, 0) // center?
            
            
            //camera.runBenchmark = true
            //camera --> blendFilter --> renderView
        
            //camera.startCapture()
            setFilter()
        }catch {
            
        }
    }
    private func getCaptureResolution(pos: AVCaptureDevice.Position) -> CGSize {
        // Define default resolution
        var resolution = CGSize(width: 0, height: 0)
        
        // Get cur video device
        
        
        let devices = AVCaptureDevice.devices(for:AVMediaType.video)
        var dev : AVCaptureDevice?
        for case let device in devices {
            if (device.position == pos) {
                dev = device
            }
        }
        
        
        let curVideoDevice = dev//useBackCamera ? backCameraDevice : frontCameraDevice
        
        // Set if video portrait orientation
        //let portraitOrientation = orientation == .Portrait || orientation == .PortraitUpsideDown
        
        // Get video dimensions
        if let formatDescription = curVideoDevice?.activeFormat.formatDescription {
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
            resolution = CGSize(width: resolution.height, height: resolution.width)
//            if (portraitOrientation) {
//                resolution = CGSize(width: resolution.height, height: resolution.width)
//            }
        }
        
        print(resolution.width)
        print(resolution.height)
        return resolution
    }
    @IBAction func onClickMode(_ sender: Any) {
        if isRecording {
            return
        }
        
        viewMenu.isHidden = false
    }
    @IBAction func onClickRec(_ sender: Any) {
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    @IBAction func onClickExport(_ sender: UIButton) {
        do {
            
            let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            let fileURL = URL(string:"save.mp4", relativeTo:documentsDir)!
            let docController = UIDocumentInteractionController(url: fileURL)
            docController.presentOptionsMenu(from: sender.frame, in:self.view, animated:true)
            
        } catch {
            fatalError("Couldn't initialize movie, error: \(error)")
        }
    }
    
    var cameraCrop : Crop!
    var bannerView : GADBannerView!
    func addBannerViewToView(_ bannerView: GADBannerView){
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewBanner.addSubview(bannerView)
        viewBanner.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: viewBanner,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: viewBanner,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    var crop1 = Crop()
    var crop2 = Crop()
    var waterMarkInput = PictureInput.init(imageName: "water_mark_no_background.png")
    let overlayFilter = OverlayBlend()
    
    func clearFilter(){
        guard camera != nil else {
            return
        }
        camera.removeAllTargets()
        camera.stopCapture()
        movie.cancel()
        movie.removeAllTargets()
        blendFilter.removeAllTargets()
        crop1.removeAllTargets()
        crop2.removeAllTargets()
        overlayFilter.removeAllTargets()
        waterMarkInput.removeAllTargets()
    }
    func setFilter(loop: Bool = true){
        guard camera != nil else {
            Utils.msgBox(self, message: "Camera Error!!!")
            AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

            return
        }
        clearFilter()
        do {
            let bundleURL = Bundle.main.resourceURL!
            
            switch currentMode {
            case 0:
                camera --> cameraCrop --> renderView
                camera.startCapture()
            case 1://love
                let movieURL = URL(string:"romance.mov", relativeTo:bundleURL)!
                movie = try MovieInput(url:movieURL, playAtActualSpeed:true, loop: loop)
                movie.playSound = true
                movie.start()
                blendFilter = AddBlend()
                movie --> crop1 --> blendFilter
                //movie --> blendFilter
                camera --> crop2 --> blendFilter
                
                if purchaseRomance {
                    blendFilter --> cameraCrop --> renderView
                }
                else {
                    waterMarkInput --> overlayFilter
                    blendFilter --> overlayFilter --> cameraCrop --> renderView
                }
                camera.startCapture()
            case 2://life
                let movieURL = URL(string:"life.mov", relativeTo:bundleURL)!
                movie = try MovieInput(url:movieURL, playAtActualSpeed:true, loop: loop)
                movie.playSound = true
                movie.start()
                blendFilter = AddBlend()
                movie --> crop1 --> blendFilter
                camera --> crop2 --> blendFilter
                if purchaseLife {
                    blendFilter --> cameraCrop --> renderView
                }
                else {
                    waterMarkInput --> overlayFilter
                    blendFilter --> overlayFilter --> cameraCrop --> renderView
                }
                camera.startCapture()
            case 3://spring
                let movieURL = URL(string:"spring.mov", relativeTo:bundleURL)!
                movie = try MovieInput(url:movieURL, playAtActualSpeed:true, loop: loop)
                movie.playSound = true
                movie.start()
                blendFilter = ScreenBlend()
                movie --> crop1 --> blendFilter
                camera --> crop2 --> blendFilter
                if purchaseSpring {
                    blendFilter --> cameraCrop --> renderView
                }
                else {
                    waterMarkInput --> overlayFilter
                    blendFilter --> overlayFilter --> cameraCrop --> renderView
                }
                
                camera.startCapture()
            case 4://horror
                let movieURL = URL(string:"horror.mov", relativeTo:bundleURL)!
                movie = try MovieInput(url:movieURL, playAtActualSpeed:true, loop: loop)
                movie.playSound = true
                movie.start()
                
                blendFilter = SoftLightBlend()
                movie --> crop1 --> blendFilter
                camera --> crop2 --> blendFilter
                if purchaseHorror {
                    blendFilter --> cameraCrop --> renderView
                }
                else {
                    waterMarkInput --> overlayFilter
                    blendFilter --> overlayFilter --> cameraCrop --> renderView
                }
                camera.startCapture()
            default:
                break
            }
        }catch{
            
        }
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let height: CGFloat = 50 //whatever height you want to add to the existing height
//        let bounds = self.navigationController!.navigationBar.bounds
//        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
//
//    }
    var index = 0
    var tagIndex = 0
    let videoFiles = ["spring.mov", "love.mov", "she.mov", "horror.mov"]
    @IBAction func onClickChangeVideoFileName(_ sender: Any) {
        index = (index + 1) % 4
        
        reloadVideo()
        
    }
    func reloadVideo(){
        let bundleURL = Bundle.main.resourceURL!
        let movieURL = URL(string:videoFiles[index], relativeTo:bundleURL)!
        
        navigationItem.title = "Camera Filter - \(videoFiles[index]) - \(tagIndex)"
        movie.removeAllTargets()
        
        movie.cancel()
        camera.removeAllTargets()
        camera.stopCapture()
        
        do {
            movie = try MovieInput(url:movieURL, playAtActualSpeed:true)
            movie --> blendFilter
            movie.start()
            
            camera --> blendFilter --> renderView
            camera.startCapture()
        } catch {
            print("Couldn't process movie with error: \(error)")
        }
    }
    @IBAction func onClickFilterType(_ sender: UIBarButtonItem) {
        do {
            camera = try Camera(sessionPreset:AVCaptureSession.Preset.vga640x480)
            camera.runBenchmark = false
            filter = SaturationAdjustment()
            blendFilter.removeAllTargets()
            tagIndex = sender.tag + 1
            switch sender.tag {
            case 0:
                blendFilter = ColorDodgeBlend() // Okay
            case 1:
                blendFilter = LinearBurnBlend() // Dark!!
            case 2:
                blendFilter = LightenBlend() // can't realize
            case 3:
                blendFilter = SoftLightBlend() // Okay but dark
            case 4:
                blendFilter = ScreenBlend() // considerable
            case 5:
                blendFilter = OverlayBlend()
            default:
                blendFilter = AddBlend()
            }
            
            reloadVideo()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }
    @objc func handlePlaybackFinished(){
        /*movie.removeAllTargets()
        
        movie.cancel()
        let bundleURL = Bundle.main.resourceURL!
        let movieURL = URL(string:"she.mov", relativeTo:bundleURL)!
        
        do {
            movie = try MovieInput(url:movieURL, playAtActualSpeed:true)
            movie --> blendFilter
            movie.start()
        } catch {
            print("Couldn't process movie with error: \(error)")
        }*/
    }
    override func viewDidAppear(_ animated: Bool) {
        setFilter()
    }
    override func viewDidDisappear(_ animated: Bool) {
        clearFilter()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var recordingTimer: Timer?
    @objc func recordingProcess() {
        seconds = seconds + 1
        lblTime.text = String(format: "%02d:%02d", seconds / 120, (seconds / 2) % 60)
        
        if recordBtn.alpha == 1.0{
            UIView.animate(withDuration: 0.4, animations: {
                self.recordBtn.alpha = 0.5
            })
        }
        else{
            UIView.animate(withDuration: 0.1, animations: {
                self.recordBtn.alpha = 1
            })
        }
    }
    @IBOutlet weak var lastRecordBtn: UIButton!
    var seconds : Int = 0
    func playDone(){
        DispatchQueue.main.async {
            self.lblTime.text = "00:00"
            if self.isRecording && self.recordingTimer != nil {
                if self.recordingTimer != nil {
                    self.recordingTimer?.invalidate()
                    self.recordingTimer = nil
                    self.recordBtn.alpha = 1
                }
                self.movieOutput?.finishRecording{
                    self.isRecording = false

                    self.camera.audioEncodingTarget = nil
                    self.movieOutput = nil
                    self.stopFilter()
                    DispatchQueue.main.async {
                        //(sender as! UIButton).titleLabel!.text = "Record"
                        self.mergeFilesWithUrl()
                    }

                }
            }
        }
    }
    @IBAction func capture(_ sender: AnyObject) {
        if (!isRecording) {
            do {
                self.isRecording = true
                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
                let fileURL = URL(string:"save_.mp4", relativeTo:documentsDir)!
                do {
                    try FileManager.default.removeItem(at:fileURL)
                } catch {
                }
                
                setFilter(loop: false)
                movie.movieDoneCallBack = playDone
                movieOutput = try MovieOutput(URL:fileURL, size:Size(width:640, height:640), liveVideo:true)
                camera.audioEncodingTarget = movieOutput
                cameraCrop --> movieOutput!
                movieOutput!.startRecording()
                self.seconds = 0
                
                recordingTimer = Timer.scheduledTimer(
                    timeInterval: 0.5,
                    target: self,
                    selector: #selector(recordingProcess),
                    userInfo: nil,
                    repeats: true
                )
                

                DispatchQueue.main.async {
                    // Label not updating on the main thread, for some reason, so dispatching slightly after this
                    //(sender as! UIButton).titleLabel!.text = "Stop"
                }
            } catch {
                fatalError("Couldn't initialize movie, error: \(error)")
            }
        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.lblTime.text = "00:00"
                if self.isRecording {
                    if self.recordingTimer != nil {
                        self.recordingTimer?.invalidate()
                        self.recordingTimer = nil
                        self.recordBtn.alpha = 1
                    }
                    self.movieOutput?.finishRecording{
                        self.isRecording = false
                        
                        self.camera.audioEncodingTarget = nil
                        self.movieOutput = nil
                        self.stopFilter()
                        DispatchQueue.main.async {
                            //(sender as! UIButton).titleLabel!.text = "Record"
                            self.mergeFilesWithUrl()
                        }
                        
                    }
                }
//            }
        }
    }
    func stopFilter(){
        clearFilter()
    }
    var interstitial: GADInterstitial!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        do  {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeMoviePlayback, options:[])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            //TODO
        }
        
        do {
//            if !AVCaptureSession.canSetSessionPreset(AVCaptureSession.Preset.high){
//                return
//            }
            camera = try Camera(sessionPreset:AVCaptureSession.Preset.high)
            
            camera.runBenchmark = false
            
            filter = SaturationAdjustment()
            
            blendFilter = LinearBurnBlend() // Dark!!
            blendFilter = LightenBlend() // can't realize
            blendFilter = ColorDodgeBlend() // Okay
            blendFilter = SoftLightBlend() // Okay but dark
            blendFilter = ScreenBlend() // considerable
            blendFilter = AddBlend()
            let bundleURL = Bundle.main.resourceURL!
            let movieURL = URL(string:"romance.mov", relativeTo:bundleURL)!
            //            let movieURL = URL(string:"test.mp4", relativeTo:bundleURL)!
            do {
                movie = try MovieInput(url:movieURL, playAtActualSpeed:true, loop: true)
                movie.playSound = true
                let size = getCaptureResolution(pos: .back)
                
                cameraCrop = Crop()
                cameraCrop.cropSizeInPixels = Size.init(width: 1024, height: 1024)
                cameraCrop.locationOfCropInPixels = Position.init(0, Float((size.height - size.width) / 2)) // center?
                
                
                crop1.cropSizeInPixels = Size.init(width: 1024, height: 1024)
                crop1.locationOfCropInPixels = Position.init(0, 0) // center?
                
                crop2.cropSizeInPixels = Size.init(width: 1024, height: 1024)
                crop2.locationOfCropInPixels = Position.init(0, 0)
                
                cameraCrop.cropSizeInPixels = Size.init(width: Float(size.width), height: Float(size.width))
                cameraCrop.locationOfCropInPixels = Position.init(0, 0) // center?
                crop1.cropSizeInPixels = Size.init(width: Float(size.width), height: Float(size.width))
                crop1.locationOfCropInPixels = Position.init(Float((videoSize.width - size.width) / 2), Float((videoSize.height - size.width) / 2)) // center?
                crop2.cropSizeInPixels = Size.init(width: Float(size.width), height: Float(size.width))
                crop2.locationOfCropInPixels = Position.init(0, 0) // center?
                setFilter()
            } catch {
                print("Couldn't process movie with error: \(error)")
            }
        } catch {
            //fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "moview_icon")!)
        
        _ = try? Utils.isUpdateAvailable { (update, error) in
            if let error = error {
                Log.error(error)
            } else if let update = update, update {
                Log.debug(update)
                Utils.msgBox(self, message: "업데이트 버전이 존재합니다.", handler:{ _ in
                    Utils.updateApp()
                })
            }
        }
        
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-5061255481889242/1458152255"//test: "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.delegate = self
        let req = GADRequest()
        req.testDevices = [kGADSimulatorID]
        bannerView.load(req)
        
        interstitial = createAndLoadInterstitial()
        //        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
        //                                                    withAdUnitID: "ca-app-pub-5061255481889242/7059044866")
        //        GADRewardBasedVideoAd.sharedInstance().delegate = self
 
        
        Appirater.appLaunched(true)
        Appirater.setAppId("1360966658")
        Appirater.setDaysUntilPrompt(3)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(3)
        Appirater.setDebug(false)
        
        waterMarkInput.processImage()
        
        loadSavedSubscription()
        fetchAvailableProducts()
    }
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    func restartFn(){
        self.setFilter()
    }
    
    func shareVideo(){
        
        loadSavedSubscription()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main" , bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        newViewController.modalTransitionStyle = .crossDissolve
        newViewController.modalPresentationStyle = .overCurrentContext
        newViewController.restartFilterFn = self.restartFn
        
        self.present(newViewController, animated:  false, completion: {
            // 0: default
            // 1: Romance
            // 2: Life
            // 3: Spring
            // 4: Horror
            switch self.currentMode {
            case 1:
                if self.purchaseRomance{
                    return
                }
            case 2:
                if self.purchaseLife {
                    return
                }
            case 3:
                if self.purchaseSpring {
                    return
                }
            case 4:
                if self.purchaseHorror {
                    return
                }
            default:
                return
            }
            
            if self.interstitial.isReady {
                self.interstitial.present(fromRootViewController: UIApplication.topViewController()!)
            } else {
                print("Ad wasn't ready")
            }
//            if GADRewardBasedVideoAd.sharedInstance().isReady == true {
//                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: UIApplication.topViewController()!)
//            }
        })
    }
    
    var purchaseSpring = false
    var purchaseRomance = false
    var purchaseHorror = false
    var purchaseLife = false

    // MARK: Purchase Method
    override func iapProductsDidLoad(){
        uploadReceipt {(success) in
            self.clearSubscription()
            if let activeSubscriptions = activeSubscriptions {
                for var item in activeSubscriptions {
                    self.saveSubscription(item.productId)
                    /*if item.productId == PurchaseVC.horrorFilter {
                     
                     }*/
                }
            }
        }
    }
}
extension ViewController {
    // MARK: Admob Methods
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-5061255481889242/7059044866")
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5061255481889242/6911705201")
        interstitial.delegate = self
//        let req = GADRequest()
//        req.testDevices = ["146fc7a93c4adf897b3c866566633ab4"]
//        interstitial.load(req)
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}
extension ViewController {
    // MARK: Purchase Methods.
    
    func saveSubscription(_ id : String){
        switch  id {
        case PurchaseVC.horrorFilter:
            purchaseHorror = true
            UserDefaults.standard.set(purchaseHorror, forKey: PurchaseVC.horrorFilter)
        case PurchaseVC.springFilter:
            purchaseSpring = true
            UserDefaults.standard.set(purchaseSpring, forKey: PurchaseVC.springFilter)
        case PurchaseVC.romanceFilter:
            purchaseRomance = true
            UserDefaults.standard.set(purchaseRomance, forKey: PurchaseVC.romanceFilter)
        case PurchaseVC.lifeFilter:
            purchaseLife = true
            UserDefaults.standard.set(purchaseLife, forKey: PurchaseVC.lifeFilter)
        default:
            break
        }
    }
    func clearSubscription(){
//        purchaseSpring = false
//        purchaseRomance = false
//        purchaseHorror = false
//        purchaseLife = false
//        UserDefaults.standard.set(false, forKey: PurchaseVC.horrorFilter)
//        UserDefaults.standard.set(false, forKey: PurchaseVC.springFilter)
//        UserDefaults.standard.set(false, forKey: PurchaseVC.romanceFilter)
//        UserDefaults.standard.set(false, forKey: PurchaseVC.lifeFilter)
    }
    func loadSavedSubscription(){
        UserDefaults.standard.register(defaults: [PurchaseVC.horrorFilter : false, PurchaseVC.springFilter: false, PurchaseVC.romanceFilter: false, PurchaseVC.lifeFilter: false])
        
        purchaseSpring = UserDefaults.standard.bool(forKey: PurchaseVC.springFilter)
        purchaseRomance = UserDefaults.standard.bool(forKey: PurchaseVC.romanceFilter)
        purchaseHorror = UserDefaults.standard.bool(forKey: PurchaseVC.horrorFilter)
        purchaseLife = UserDefaults.standard.bool(forKey: PurchaseVC.lifeFilter)
    }
    
}
extension ViewController {
    func mergeFilesWithUrl()
    {
        do{
        let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
        let videoUrl = URL(string:"save_.mp4", relativeTo:documentsDir)!
            var filename = "";
            switch currentMode{
            case 1://romance
                filename = "romance.mov"
            case 2://life
                filename = "life.mov"
            case 3://spring
                filename = "spring.mov"
            case 4://horror
                filename = "horror.mov"
            default:
                do {
                    try FileManager.default.removeItem(at:URL(string:"save.mp4", relativeTo:documentsDir)!)
                } catch {
                }
                try FileManager.default.copyItem(at: videoUrl, to: URL(string:"save.mp4", relativeTo:documentsDir)!)
                
                self.shareVideo()
                return;
            }
            
            let bundleURL = Bundle.main.resourceURL!
            let audioUrl = URL(string:filename, relativeTo:bundleURL)!
            
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        
        //start merge
        
        let aVideoAsset : AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
            mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
            mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
            
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        
        
        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            
            
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
            if aVideoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
            try mutableCompositionAudioTrack[1].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAsset.tracks(withMediaType: AVMediaType.audio)[0], at: kCMTimeZero)
            }
            
            //Use this instead above line if your audiofile and video file's playing durations are same
            
            //            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), ofTrack: aAudioAssetTrack, atTime: kCMTimeZero)
            
        }catch{
            
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration )
        
        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
        
        mutableVideoComposition.renderSize = CGSize(width: 640, height: 640)
        
        //        playerItem = AVPlayerItem(asset: mixComposition)
        //        player = AVPlayer(playerItem: playerItem!)
        //
        //
        //        AVPlayerVC.player = player
        
        
        
        //find your video on this URl
        let savePathUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/save.mp4")
        do {
            try FileManager.default.removeItem(at:savePathUrl)
        } catch {
        }
            
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSessionStatus.completed:
                DispatchQueue.main.async {
                    self.shareVideo()
                }
                print("success")
            case  AVAssetExportSessionStatus.failed:
                print("failed \(assetExport.error)")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error)")
            default:
                print("complete")
            }
        }
        
        }catch{
            
        }
    }
}
