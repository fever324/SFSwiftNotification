SFSwiftNotification
=============


Simple custom user notifications. The default theme tries to mimic native iOS 8 style. But the view is fully customizable.


Install
--------------------

* Manually:
Copy the file ```SFSwiftNotification.swift``` to your project.


* CocoaPods: (Soon available)



Usage
--------------------


In your ViewController
***If you want to simply display a notification using the following line.
```swift 
        let notifyView = SFSwiftNotification(title: "hi")
        notifyView.show()
```
######If you want to handle tap or change animationType and directions, you can use the the following initializer  
```swift
    let notifyView = SFSwiftNotification(title: "Hi",
                                 animationType: AnimationType.AnimationTypeCollision,
                                     direction: Direction.LeftToRight,
                                      delegate: self)
```
#####And of course you need to implement SFSwiftNotificationProtocol
```swift
class ViewController: UIViewController, SFSwiftNotificationProtocol {
...
    func didNotifyFinishedAnimation(results: Bool) {
        
        println("SFSwiftNotification finished animation")
    }
    
    func didTapNotification() {
        
        let tapAlert = UIAlertController(title: "SFSwiftNotification",
            message: "You just tapped the notificatoion",
            preferredStyle: UIAlertControllerStyle.Alert)
        tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        self.presentViewController(tapAlert, animated: true, completion: nil)
    }
...
}
```
#####To start the notification:

```swift
    @IBAction func notify(sender : AnyObject) {
        notifyView.show()    
    }
```

Settings
--------------------

AnimationTypes:

```swift
    .AnimationTypeCollision
    .AnimationTypeBounce
```

Directions:

```swift
    .TopToBottom
    .LeftToRight
    .RightToLeft
```

Screen
--------------------

![Demo DEFAULT](https://raw.github.com/sferrini/SFSwiftNotification/master/Gif/SFSwiftNotificationBlue.gif)

![Demo DEFAULT](https://raw.github.com/sferrini/SFSwiftNotification/master/Gif/SFSwiftNotification.gif)

![Demo DEFAULT](https://raw.github.com/oduwa/SFSwiftNotification/master/Gif/SFSwiftNotificationTap.gif)
