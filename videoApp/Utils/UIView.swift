//
//  UIView.swift
//  SudaKorean
//
//  Created by LeeJongMin on 28/10/2017.
//  Copyright © 2017 flymax. All rights reserved.
//

import UIKit
extension String {
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
}
extension UITextField{
    
    func addDoneButtonToKeyboard(myAction:Selector?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: nil, action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
extension UIImage {
    
    func scaledToFit(toSize newSize: CGSize) -> UIImage {
        if (size.width < newSize.width && size.height < newSize.height) {
            return copy() as! UIImage
        }
        
        let widthScale = newSize.width / size.width
        let heightScale = newSize.height / size.height
        
        let scaleFactor = widthScale < heightScale ? widthScale : heightScale
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        return self.scaled(toSize: scaledSize, in: CGRect(x: 0.0, y: 0.0, width: scaledSize.width, height: scaledSize.height))
    }
    
    func scaled(toSize newSize: CGSize, in rect: CGRect) -> UIImage {
        if UIScreen.main.scale == CGFloat(2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, !hasAlphaChannel, 2.0)
        }
        else {
            UIGraphicsBeginImageContext(newSize)
        }
        
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
    var hasAlphaChannel: Bool {
        guard let alpha = cgImage?.alphaInfo else {
            return false
        }
        return alpha == CGImageAlphaInfo.first ||
            alpha == CGImageAlphaInfo.last ||
            alpha == CGImageAlphaInfo.premultipliedFirst ||
            alpha == CGImageAlphaInfo.premultipliedLast
    }
}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
@IBDesignable extension UIView {
    @IBInspectable var borderVColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderVWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerVRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable var shadowColor: UIColor? {
        set {
            layer.shadowColor = newValue?.cgColor
        }
        get {
            guard let color = layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }
    @IBInspectable var shadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }
}
extension UIViewController{
    func showToast(_ message : String) {
        DispatchQueue.main.async {
            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 55))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.95)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
            toastLabel.text = "  " + message + "  "
            toastLabel.alpha = 1.0
            toastLabel.numberOfLines = 2
            //        toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            
            toastLabel.translatesAutoresizingMaskIntoConstraints = false;
            let myHorizontalConstraint = NSLayoutConstraint(item: toastLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let myVerticalConstraint = NSLayoutConstraint(item: toastLabel, attribute: NSLayoutAttribute.bottom , relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -100)
            let widthConstraint = NSLayoutConstraint(item: toastLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant:0)
            let myHeightConstraint = NSLayoutConstraint(item: toastLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 55)
            
            NSLayoutConstraint.activate([myHorizontalConstraint,myVerticalConstraint,myHeightConstraint, widthConstraint])
            
            UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.9
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(view: self)
        navigationBarImageView!.isHidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(view: self)
        navigationBarImageView!.isHidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(view: subview) {
                return imageView
            }
        }
        return nil
    }
}

@IBDesignable
class DesignableUITextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: color])
    }
}

public class ScaleAspectFitImageView : UIImageView {
    /// constraint to maintain same aspect ratio as the image
    private var aspectRatioConstraint:NSLayoutConstraint? = nil
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setup()
    }
    
    public override init(frame:CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    public override init(image: UIImage!) {
        super.init(image:image)
        self.setup()
    }
    
    public override init(image: UIImage!, highlightedImage: UIImage?) {
        super.init(image:image,highlightedImage:highlightedImage)
        self.setup()
    }
    
    override public var image: UIImage? {
        didSet {
            self.updateAspectRatioConstraint()
        }
    }
    
    private func setup() {
        self.contentMode = .scaleAspectFit
        self.updateAspectRatioConstraint()
    }
    
    /// Removes any pre-existing aspect ratio constraint, and adds a new one based on the current image
    private func updateAspectRatioConstraint() {
        // remove any existing aspect ratio constraint
        if let c = self.aspectRatioConstraint {
            self.removeConstraint(c)
        }
        self.aspectRatioConstraint = nil
        
        if let imageSize = image?.size, imageSize.height != 0
        {
            let aspectRatio = imageSize.width / imageSize.height
            let c = NSLayoutConstraint(item: self, attribute: .width,
                                       relatedBy: .equal,
                                       toItem: self, attribute: .height,
                                       multiplier: aspectRatio, constant: 0)
            // a priority above fitting size level and below low
            //c.priority = UILayoutPriority(rawValue: (UILayoutPriority.defaultLow.rawValue + UILayoutPriority.fittingSizeLevel.rawValue) / 2.0)
            self.addConstraint(c)
            self.aspectRatioConstraint = c
        }
    }
}


extension UITableViewRowAction {
    
    func setIcon(iconImage: UIImage, backColor: UIColor, cellHeight: CGFloat, iconSizePercentage: CGFloat)
    {
        
        let iconHeight = cellHeight * iconSizePercentage
        let margin = (cellHeight - iconHeight) / 2 as CGFloat
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cellHeight, height: cellHeight), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        backColor.setFill()
        context!.fill(CGRect(x:0, y:0, width:cellHeight, height:cellHeight))
        //        context!.fill(CGRect(x:0, y:0, width:80, height:200))
        
        iconImage.draw(in: CGRect(x: 10, y: margin, width: iconHeight, height: iconHeight))
        
        let actionImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.backgroundColor = UIColor.init(patternImage: actionImage!)
        
    }
    func setIcon(iconImage: UIImage, backColor: UIColor, cellHeight: CGFloat, iconHeight: CGFloat)
    {
        
        let margin = (cellHeight - iconHeight) / 2 as CGFloat
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cellHeight, height: cellHeight), false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        backColor.setFill()
        context!.fill(CGRect(x:0, y:0, width:cellHeight, height:cellHeight))
        //        context!.fill(CGRect(x:0, y:0, width:80, height:200))
        
        iconImage.draw(in: CGRect(x: 10, y: margin, width: iconHeight, height: iconHeight))
        
        let actionImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.backgroundColor = UIColor.init(patternImage: actionImage!)
        
    }
}
extension UIViewController : UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UIAlertController {
    
    private struct AssociatedKeys {
        static var blurStyleKey = "UIAlertController.blurStyleKey"
    }
    
    public var blurStyle: UIBlurEffectStyle {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.blurStyleKey) as? UIBlurEffectStyle ?? .extraLight
        } set (style) {
            objc_setAssociatedObject(self, &AssociatedKeys.blurStyleKey, style, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    public var cancelButtonColor: UIColor? {
        //return blurStyle == .dark ? UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0) : nil
        return UIColor(red: 25/255, green: 28/255, blue:28/255, alpha: 1.0)
    }
    
    private var visualEffectView: UIVisualEffectView? {
        if let presentationController = presentationController, presentationController.responds(to: Selector(("popoverView"))), let view = presentationController.value(forKey: "popoverView") as? UIView // We're on an iPad and visual effect view is in a different place.
        {
            return view.recursiveSubviews.flatMap({$0 as? UIVisualEffectView}).first
        }
        
        return view.recursiveSubviews.flatMap({$0 as? UIVisualEffectView}).first
    }
    private var okActionView: UIView? {
        return view.recursiveSubviews.flatMap({$0 as? UILabel}).first(where: {
            $0.text == actions.first(where: { $0.style == .default })?.title
        })?.superview?.superview
    }
    private var cancelActionView: UIView? {
        return view.recursiveSubviews.flatMap({$0 as? UILabel}).first(where: {
            $0.text == actions.first(where: { $0.style == .cancel })?.title
        })?.superview?.superview
    }
    
    public convenience init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle, blurStyle: UIBlurEffectStyle) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        self.blurStyle = blurStyle
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //        visualEffectView?.effect = UIBlurEffect(style: blurStyle)
        //        cancelActionView?.backgroundColor = cancelButtonColor
        //        okActionView?.backgroundColor = cancelButtonColor
    }
    
}
extension UIView {
    
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.flatMap({$0})
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
}

extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func getSearchBarTextField() -> UITextField? {
        
        return getViewElement(type: UITextField.self)
    }
    
    func setTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedStringKey.foregroundColor: color])
        }
    }
    
    func setTextFieldClearButtonColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            
            let button = textField.value(forKey: "clearButton") as! UIButton
            //            if let image = button.imageView?.image {
            //                button.setImage(image.transform(withNewColor: color), for: .normal)
            //            }
            let img = UIImage(named: "btn-text_clear.png")?.withRenderingMode(.alwaysTemplate)
            button.setImage(img, for: .normal)
            button.tintColor = color //UIColor.init(red: 188/255, green: 190/255, blue: 192/255, alpha: 1.0)
        }
    }
    
    func setSearchImageColor(color: UIColor) {
        
        if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
            imageView.image = imageView.image?.transform(withNewColor: color)
        }
    }
}
extension UIImage {
    
    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}




open class ISPageControl: UIControl {
    private let limit = 5
    private var fullScaleIndex = [0, 1, 2]
    private var dotLayers: [CALayer] = []
    private var diameter: CGFloat { return radius * 2 }
    private var centerIndex: Int { return fullScaleIndex[1] }
    
    open var currentPage = 0 {
        didSet {
            guard numberOfPages > currentPage else {
                return
            }
            update()
        }
    }
    
    @IBInspectable open var inactiveTintColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var currentPageTintColor: UIColor = #colorLiteral(red: 0, green: 0.6276981994, blue: 1, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var radius: CGFloat = 5 {
        didSet {
            updateDotLayersLayout()
        }
    }
    
    @IBInspectable open var padding: CGFloat = 8 {
        didSet {
            updateDotLayersLayout()
        }
    }
    
    @IBInspectable open var minScaleValue: CGFloat = 0.4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var middleScaleValue: CGFloat = 0.7 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var numberOfPages: Int = 0 {
        didSet {
            setupDotLayers()
            isHidden = hideForSinglePage && numberOfPages <= 1
        }
    }
    
    @IBInspectable open var hideForSinglePage: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var inactiveTransparency: CGFloat = 0.4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init(frame: CGRect, numberOfPages: Int) {
        super.init(frame: frame)
        self.numberOfPages = numberOfPages
        setupDotLayers()
    }
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let minValue = min(7, numberOfPages)
        return CGSize(width: CGFloat(minValue) * diameter + CGFloat(minValue - 1) * padding, height: diameter)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        dotLayers.forEach {
            if borderWidth > 0 {
                $0.borderWidth = borderWidth
                $0.borderColor = borderColor.cgColor
            }
        }
        
        update()
    }
}

private extension ISPageControl {
    
    func setupDotLayers() {
        dotLayers.forEach{ $0.removeFromSuperlayer() }
        dotLayers.removeAll()
        
        (0..<numberOfPages).forEach { _ in
            let dotLayer = CALayer()
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
        
        updateDotLayersLayout() // 이부분은 변경이 필요할듯
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    func updateDotLayersLayout() {
        let floatCount = CGFloat(numberOfPages)
        let x = (bounds.size.width - diameter * floatCount - padding * (floatCount - 1)) * 0.5
        let y = (bounds.size.height - diameter) * 0.5
        var frame = CGRect(x: x, y: y, width: diameter, height: diameter)
        
        dotLayers.forEach {
            $0.cornerRadius = radius
            $0.frame = frame
            frame.origin.x += diameter + padding
        }
    }
    
    func setupDotLayersPosition() {
        let centerLayer = dotLayers[centerIndex]
        centerLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        dotLayers.enumerated().filter{ $0.offset != centerIndex }.forEach {
            let index = abs($0.offset - centerIndex)
            let interval = $0.offset > centerIndex ? diameter + padding : -(diameter + padding)
            $0.element.position = CGPoint(x: centerLayer.position.x + interval * CGFloat(index), y: $0.element.position.y)
        }
    }
    
    func setupDotLayersScale() {
        dotLayers.enumerated().forEach {
            guard let first = fullScaleIndex.first, let last = fullScaleIndex.last else {
                return
            }
            
            var transform = CGAffineTransform.identity
            if !fullScaleIndex.contains($0.offset) {
                var scaleValue: CGFloat = 0
                if abs($0.offset - first) == 1 || abs($0.offset - last) == 1 {
                    scaleValue = min(middleScaleValue, 1)
                } else if abs($0.offset - first) == 2 || abs($0.offset - last) == 2 {
                    scaleValue = min(minScaleValue, 1)
                } else {
                    scaleValue = 0
                }
                transform = transform.scaledBy(x: scaleValue, y: scaleValue)
            }
            
            $0.element.setAffineTransform(transform)
        }
    }
    
    func update() {
        dotLayers.enumerated().forEach() {
            $0.element.backgroundColor = $0.offset == currentPage ? currentPageTintColor.cgColor : inactiveTintColor.withAlphaComponent(inactiveTransparency).cgColor
        }
        
        guard numberOfPages > limit else {
            return
        }
        
        changeFullScaleIndexsIfNeeded()
        setupDotLayersPosition()
        setupDotLayersScale()
    }
    
    func changeFullScaleIndexsIfNeeded() {
        guard !fullScaleIndex.contains(currentPage) else {
            return
        }
        
        // TODO: Refactoring
        let moreThanBefore = (fullScaleIndex.last ?? 0) < currentPage
        if moreThanBefore {
            fullScaleIndex[0] = currentPage - 2
            fullScaleIndex[1] = currentPage - 1
            fullScaleIndex[2] = currentPage
        } else {
            fullScaleIndex[0] = currentPage
            fullScaleIndex[1] = currentPage + 1
            fullScaleIndex[2] = currentPage + 2
        }
    }
}
