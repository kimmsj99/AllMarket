
//  AppDelegate.swift
//  AllMarket
//
//  Created by MAC on 2017. 8. 9..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftLoader
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let reachability = Reachability()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        L102Localizer.DoTheMagic()
        
        let storyboard = UIStoryboard.init(name : "Main", bundle : Bundle.main)
        let myData : UserDefaults = UserDefaults.standard
        var rootController : UIViewController
        
        //언어선택을 했으면 로그인 화면으로 보여주기
        if( myData.object(forKey: "selectLanguage" ) != nil) {
            rootController = storyboard.instantiateViewController(withIdentifier: "LoginView" )
            //자동로그인이 체크 됐으면 바로 Home 화면 보여주기
            if (myData.object(forKey: "email") != nil && (myData.object(forKey: "pass") != nil)) {
                rootController = storyboard.instantiateViewController(withIdentifier: "Home" )
            }
        } else {
//            myData.set(1, forKey: "selectLanguage");
            rootController = storyboard.instantiateViewController(withIdentifier: "Language" )
        }
        
        self.window = UIWindow( frame: UIScreen.main.bounds )
        self.window?.rootViewController = rootController
        self.window?.makeKeyAndVisible()
        
        Thread.sleep(forTimeInterval: 2.0)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // RemoteNotification 권한 설정..
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().remoteMessageDelegate = self
        
        FirebaseApp.configure()  // 파이어베이스 구성!
        
        // 요넘 덕분에 background, terminated 상태에서 노티를 받을 수 있다.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        
        setInipay()
        setReachability()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url as URL!, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //setAPNSToken:type:에 APN 토큰 및 토큰 유형을 제공합니다. type의 값을 올바르게 설정해야 함. 샌드박스 환경의 경우 FIRInstanceIDAPNSTokenTypeSandbox, 운영 환경의 경우 FIRInstanceIDAPNSTokenTypeProd로 설정. 유형을 잘못 설정하면 메시지가 앱에 전송되지 않음.
        
        Messaging.messaging().apnsToken = deviceToken as Data
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        FBSDKAppEvents.activateApp()
    }
    
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        SwiftLoader.show(title: "앱에 필요한 데이터를 생성 중입니다...", animated: true)
        
        if UserDefaults.standard.string(forKey: "token") == nil {
            if let refreshedToken = InstanceID.instanceID().token() {
                print("InstanceID token: \(refreshedToken)")
                
                UserDefaults.standard.set(refreshedToken, forKey: "token")
            }
            
        }else{
            print("token is exist")
        }
        
        SwiftLoader.hide()
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().disconnect()
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    
    func setInipay() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
    }
    
    func setReachability() {
        //인터넷 연결 체크
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            
            DispatchQueue.main.async {
                print("not reachable")
                
                let alertController = UIAlertController(title: "networdCheck".localized, message: "appExit".localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "okTitle".localized, style: .default, handler: { (UIAlertAction) in
                    exit(0)
                })
                
                alertController.addAction(okAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        
        let dic = userInfo as! NSDictionary
        
        print("[ dic ] linkType : \(dic)")
        
        let storyboard = UIStoryboard.init(name : "Main", bundle : Bundle.main)
        
        let linktype = dic["linktype"] as! String
        
        switch linktype {
        case "1":
            print("상품")
            
            let url = dic["link"] as! String
            print("url: \(url)")
            UserDefaults.standard.set(url, forKey: "ItemUrl")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "NaviInfo") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        case "2":
            print("이벤트")
            
            let url = dic["link"] as! String
            print("url: \(url)")
            UserDefaults.standard.set(url, forKey: "EventUrl")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "NEventDetail") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        case "3":
            print("팔로우")
            
            let idx = dic["link"] as! String
            print("idx: \(idx)")
            UserDefaults.standard.set(idx, forKey: "idx")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "UserProfile") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        case "4":
            print("관리자")
        case "5":
            print("답변 도착")
            
            let url = dic["link"] as! String
            UserDefaults.standard.set("알림", forKey: "questionAlert")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "WKQuestion") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        default:
            return
        }
        
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // on Foreground & onActive 앱이 구동 중일 때 푸쉬가 올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print("\n[ FCM ] userInfo : \(userInfo)\n")
        
        // 앱이 구동 중일 때 푸쉬가 올 때, 뱃지 컨트롤 가능.
        completionHandler([.alert, .badge, .sound])   // completionHandler 에 모든 일들을 넣어줘야 끝난다.  //completionHandler([])
    }
    
    // on Foreground/ Background & onDidBecomeActive 푸시 알람을 눌러서 앱이 켜질 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("\n[ FCM ] userInfo2 : \(userInfo)\n")
        
        let dic = userInfo as! NSDictionary
        
        print("[ dic ] linkType : \(dic)")
        
        let linktype = dic["link근데 type"] as! String
        
        let storyboard = UIStoryboard.init(name : "Main", bundle : Bundle.main)
        
        switch linktype {
        case "1":
            print("상품")
            
            let url = dic["link"] as! String
            print("url: \(url)")
            UserDefaults.standard.set(url, forKey: "ItemUrl")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "NaviInfo") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        case "2":
            print("이벤트")
            
            let url = dic["link"] as! String
            print("url: \(url)")
            UserDefaults.standard.set(url, forKey: "EventUrl")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "NEventDetail") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        case "3":
            print("팔로우")
            
            let idx = dic["link"] as! String
            print("idx: \(idx)")
            UserDefaults.standard.set(idx, forKey: "idx")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "UserProfile") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
            
        case "4":
            print("관리자")
        case "5":
            print("답변 도착")
            
            let url = dic["link"] as! String
            UserDefaults.standard.set("알림", forKey: "questionAlert")
            if let topController = UIApplication.topViewController() {
                if let naviVC = storyboard.instantiateViewController(withIdentifier: "WKQuestion") as? NavigationController {
                    topController.present(naviVC, animated: false, completion: nil)
                }
            }
        default:
            return
        
        }
        
        // 푸시착알람을 눌러서 앱이 켜질 때
        completionHandler()
    }
    
    
}


extension AppDelegate : MessagingDelegate {
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.
    public func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
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
