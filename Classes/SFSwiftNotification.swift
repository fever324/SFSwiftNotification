//
//  SFSwiftNotification.swift
//  SFSwiftNotification
//
//  Created by Simone Ferrini on 13/07/14.
//  Copyright (c) 2014 sferrini. All rights reserved.
//

import UIKit

enum AnimationType {
    case AnimationTypeCollision
    case AnimationTypeBounce
}

struct AnimationSettings {
    var duration:NSTimeInterval = 0.5
    var delay:NSTimeInterval = 1
    var damping:CGFloat = 0.6
    var velocity:CGFloat = 0.9
    var elasticity:CGFloat = 0.3
}

enum Direction {
    case TopToBottom
    case LeftToRight
    case RightToLeft
}

protocol SFSwiftNotificationProtocol {
    func didNotifyFinishedAnimation(results: Bool)
    func didTapNotification(notification: SFSwiftNotification)
}

class SFSwiftNotification: UIView, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate {
    
    var title = UILabel()
    var icon = UIImageView()
    var animationType:AnimationType?
    var animationSettings = AnimationSettings()
    var direction:Direction?
    var dynamicAnimator = UIDynamicAnimator()
    var delegate: SFSwiftNotificationProtocol?
    var offScreenFrame = CGRect()
    var onScreenFrame = CGRect()
    
    let iconSize:CGFloat = 40
    let padding:CGFloat = 5

    private var hided = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(title: String) {
        let size = SFSwiftNotification.getNotificationSize()
        super.init(frame:size)
        addSelfToTopControllerView()
        
        self.animationType = .AnimationTypeCollision
        self.direction = .TopToBottom
        
        setUpLabel(title)
        //setUpIcon(UIImage(named: "obama")!)

        useJDIDefaultStyle()
        addSwipeRecognizer()
        
        setOffScreenPosition()
    }
    
    init(title:String, icon:UIImage) {
    
        let size = SFSwiftNotification.getNotificationSize()
        super.init(frame:size)
        self.setUpIcon(icon)
        addSelfToTopControllerView()
        
        self.animationType = .AnimationTypeCollision
        self.direction = .TopToBottom
        
        setUpLabel(title)
        //setUpIcon(UIImage(named: "obama")!)
        
        useJDIDefaultStyle()
        addSwipeRecognizer()
        
        setOffScreenPosition()
    }
    
    init(title: String?, animationType:AnimationType, direction:Direction, delegate: SFSwiftNotificationProtocol?) {
        let size = SFSwiftNotification.getNotificationSize()
        super.init(frame:size)
        addSelfToTopControllerView()

        self.animationType = animationType
        self.direction = direction
        
        setUpLabel(title)
        if let delegate = delegate {
            addTapRecognizer(delegate)
        }
        addSwipeRecognizer()

        setOffScreenPosition()
    }
    
    func invokeTapAction() {
        self.delegate!.didTapNotification(self)
    }
    
    func setOffScreenPosition() {
        
        self.offScreenFrame = self.frame
        
        switch direction! {
        case .TopToBottom:
            self.offScreenFrame.origin.y = -self.frame.size.height
        case .LeftToRight:
            self.offScreenFrame.origin.x = -self.frame.size.width
        case .RightToLeft:
            self.offScreenFrame.origin.x = +self.frame.size.width
        }
        
        self.frame = offScreenFrame
    }
    
    func animate(toFrame:CGRect, delay:NSTimeInterval) {
        
        self.onScreenFrame = toFrame
        self.animationSettings.delay = delay

        switch self.animationType! {
        case .AnimationTypeCollision:
            setupCollisionAnimation(onScreenFrame)
            
        case .AnimationTypeBounce:
            setupBounceAnimation(onScreenFrame, delay: delay)
        }

    }
    
    func setupCollisionAnimation(toFrame:CGRect) {
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: self.superview!)
        self.dynamicAnimator.delegate = self
        
        let elasticityBehavior = UIDynamicItemBehavior(items: [self])
        elasticityBehavior.elasticity = animationSettings.elasticity;
        self.dynamicAnimator.addBehavior(elasticityBehavior)
        
        let gravityBehavior = UIGravityBehavior(items: [self])
        self.dynamicAnimator.addBehavior(gravityBehavior)
        
        let collisionBehavior = UICollisionBehavior(items: [self])
        collisionBehavior.collisionDelegate = self
        self.dynamicAnimator.addBehavior(collisionBehavior)
        
        collisionBehavior.addBoundaryWithIdentifier("BoundaryIdentifierBottom", fromPoint: CGPointMake(-self.frame.width, self.frame.height+0.5), toPoint: CGPointMake(self.frame.width*2, self.frame.height+0.5))
        
        switch self.direction! {
        case .TopToBottom:
            break
        case .LeftToRight:
            collisionBehavior.addBoundaryWithIdentifier("BoundaryIdentifierRight", fromPoint: CGPointMake(toFrame.width-0.5, 0), toPoint: CGPointMake(toFrame.width-0.5, toFrame.height))
            gravityBehavior.gravityDirection = CGVectorMake(10, 1)
        case .RightToLeft:
            collisionBehavior.addBoundaryWithIdentifier("BoundaryIdentifierLeft", fromPoint: CGPointMake(+0.5, 0), toPoint: CGPointMake(+0.5, toFrame.height))
            gravityBehavior.gravityDirection = CGVectorMake(-10, 1)
        }
    }
    
    func setupBounceAnimation(toFrame:CGRect , delay:NSTimeInterval) {
        
        UIView.animateWithDuration(animationSettings.duration,
            delay: animationSettings.delay,
            usingSpringWithDamping: animationSettings.damping,
            initialSpringVelocity: animationSettings.velocity,
            options: (.BeginFromCurrentState | .AllowUserInteraction),
            animations: {
                self.frame = toFrame
            },
            completion: {
                (value: Bool) in
                self.hideWithDelay()
            }
        )
    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        hideWithDelay()
    }
    
    private func hideWithDelay() {
        if(!hided) {
            self.hided = true
            UIView.animateWithDuration(animationSettings.duration,
                delay: animationSettings.delay,
                usingSpringWithDamping: animationSettings.damping,
                initialSpringVelocity: animationSettings.velocity,
                options: nil,
                animations:{
                    self.frame = self.offScreenFrame
                },
                completion: {
                    (value: Bool) in
                    self.delegate?.didNotifyFinishedAnimation(true)
                    self.removeFromSuperview()
                }
            )
        }
    }
    
    func hide() {
        if(!hided) {
            self.hided = true
            UIView.animateWithDuration(animationSettings.duration,
                delay: 0,
                usingSpringWithDamping: animationSettings.damping,
                initialSpringVelocity: animationSettings.velocity,
                options: nil,
                animations:{
                    self.frame = self.offScreenFrame
                },
                completion: {
                    (value: Bool) in
                    self.delegate?.didNotifyFinishedAnimation(true)
                    self.removeFromSuperview()
                }
            )
        }
    }
    
    func show(){
        self.animate(self.onScreenFrame, delay: self.animationSettings.delay)
    }
    
    private func setUpIcon(image:UIImage) {
        icon.frame = CGRect(x: padding, y: self.frame.height / 2.0 - iconSize / 2.0, width: iconSize, height: iconSize)
        icon.image = image
        self.addSubview(icon)
    }
    
    func setIconToCircular() {
        self.icon.layer.cornerRadius = self.icon.frame.size.width / 2.0;
        self.icon.clipsToBounds = true
    }
    
    func setIconToSquare() {
        self.icon.layer.cornerRadius = 0
    }
    
    private func setUpLabel(optionalTitle:String?) {
        var containsImage = icon.image != nil
        var width = containsImage ? self.frame.width - iconSize : self.frame.width
        var titleFrame = CGRect(x: iconSize + padding, y: 0, width: width, height: self.frame.height)
        
        title = UILabel(frame: titleFrame)
        title.numberOfLines = 2
        title.textAlignment = containsImage ? NSTextAlignment.Left : NSTextAlignment.Center

        if let titleString = optionalTitle{
            title.text = titleString as String
        }
        
        var xPosition = containsImage ? iconSize + padding * 2 : padding
        title.frame.origin = CGPoint(x: xPosition, y: self.frame.height / 2.0 - title.frame.height / 2)

        self.addSubview(title)
    }
    
    func setTitleText(text:String) {
        self.title.text = text
    }
    
    func setTitleColor(color:UIColor){
        self.title.textColor = color
    }
    
    func setNotificationBackgroundColor(color:UIColor) {
        self.backgroundColor = color
    }
    
    
    static func getNotificationSize() -> CGRect {
        var width = UIScreen.mainScreen().bounds.width
        let size = CGRectMake(0, 0, CGRectGetMaxX(UIScreen.mainScreen().bounds), 44+8)
        return size
    }
    
    func setDelayTime(interval: NSTimeInterval){
        self.animationSettings.delay = interval
    }
    
    
    // Helper functions
    private func getTopViewController() -> UIViewController {
        var topController:UIViewController?
        if var controller = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = controller.presentedViewController {
                controller = presentedViewController
            }
            topController = controller
        }
        return topController!
    }
    
    private func addSelfToTopControllerView() {
        let topController = getTopViewController()
        topController.view.addSubview(self)
    }
    
    func addTapRecognizer(delegate: SFSwiftNotificationProtocol) {
        // Create gesture recognizer to detect notification touches
        self.delegate = delegate
        var tapReconizer = UITapGestureRecognizer()
        tapReconizer.addTarget(self, action: "invokeTapAction")
        
        // Add Touch recognizer to notification view
        self.addGestureRecognizer(tapReconizer)

    }
    
    private func addSwipeRecognizer() {
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeUp)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        println("gesture recognized \(gesture)")
    }
    
    private func useJDIDefaultStyle() {
        var green =  UIColor(red: 112/255.0, green: 228/255.0, blue: 151/255.0, alpha: 1.0)
        
        var blackColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        setNotificationBackgroundColor(green)
        setTitleColor(UIColor.whiteColor())
    }
    
}
