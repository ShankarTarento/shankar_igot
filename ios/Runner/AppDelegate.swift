import UIKit
import Flutter
import Firebase
import Smartech
import SmartPush
import smartech_base

@main
@objc class AppDelegate: FlutterAppDelegate,SmartechDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    UNUserNotificationCenter.current().delegate = self
    Smartech.sharedInstance().initSDK(with: self, withLaunchOptions: launchOptions)
    SmartPush.sharedInstance().registerForPushNotificationWithDefaultAuthorizationOptions()
    Smartech.sharedInstance().setDebugLevel(.verbose)
    Smartech.sharedInstance().trackAppInstallUpdateBySmartech()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    SmartPush.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken) 
  }
    
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    SmartPush.sharedInstance().didFailToRegisterForRemoteNotificationsWithError(error)
  }
    
  //MARK:- UNUserNotificationCenterDelegate Methods
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    SmartPush.sharedInstance().willPresentForegroundNotification(notification)
    completionHandler([.alert, .badge, .sound])
  }
    
  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
  // MARK: Adding the delay of 5ms in didReceive response class will give the pn_clicked event in Terminated state also. Replace existing code with the below lines.
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
    SmartPush.sharedInstance().didReceive(response)
    completionHandler()
    })
  }
    
  func handleDeeplinkAction(withURLString deeplinkURLString: String, andNotificationPayload notificationPayload: [AnyHashable : Any]?) {
    //    fabfurni://productPage//, http, https
    NSLog("SMTL deeplink Native---> \(deeplinkURLString)")
    SmartechBasePlugin.handleDeeplinkAction(deeplinkURLString, andCustomPayload: notificationPayload)
    }
} 
