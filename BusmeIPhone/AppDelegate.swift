//
//  AppDelegate.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import UIKit
import CoreData

let INITIAL_URL = "http://busme-apis.herokuapp.com/apis/d1/get"
let APP_PLATFORM = "iOS"

class RestartOnCancel : UIResponder, UIAlertViewDelegate {
    var api : DiscoverApiVersion1
    var eventName : String
    var eventData : AnyObject?
    
    init(api : DiscoverApiVersion1, eventName : String, eventData : AnyObject? = nil) {
        self.api = api
        self.eventName = eventName
        self.eventData = eventData
    }
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: "restart:", userInfo: nil, repeats: false)
        }
    }
    func restart() {
        api.uiEvents.postEvent(eventName, data: eventData!)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BuspassEventListener {

    var window: UIWindow?
    var configurator = Configurator()
    var api : DiscoverApiVersion1!
    var navigationController : UINavigationController!
    var mainController : MainController?
    var httpClient : HttpClient?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        
        
        let mainViewController = UIViewController()
        
        self.navigationController = UINavigationController(rootViewController: mainViewController)
        window!.rootViewController = navigationController
        
        self.httpClient = HttpClient(queue: GlobalBackgroundQueue)
        self.api = DiscoverApiVersion1(httpClient: httpClient!, initialUrl: INITIAL_URL)
        self.mainController = MainController(configurator: configurator, discoverApi: api)
        
        registerForEvents()
        
        let eventData = MainEventData()
        eventData.dialog = searchDialog("Contacting Bus Server", message: "")
        api.uiEvents.postEvent("Main:init", data: eventData)
        return true
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("Main:Init:return", listener: self)
        api.uiEvents.registerForEvent("Main:Discover:Init:return", listener: self)
        api.uiEvents.registerForEvent("Main:Master:Init:return", listener: self)
    }
    
    func searchDialog(title : String, message : String) -> UIAlertView {
        let dialog =  UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        dialog.show()
        return dialog
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        let eventData = event.eventData as? MainEventData
        if ("Main:Init:return" == eventName) {
            onMainInitReturn(eventData!)
        } else if ("Main:Discover:Init:return" == eventName) {
            onDiscoverInitReturn(eventData!)
        } else if ("Main:Master:Init:return" == eventName) {
            onMasterInitReturn(eventData!)
        }
    }
    
    var networkErrorDialog : UIAlertView?
    
    func showTemporaryNetworkingError(title: String, message: String) {
        self.networkErrorDialog = UIAlertView(title: title,
            message: message,
            delegate: self,
            cancelButtonTitle: "OK"
        )
        self.networkErrorDialog?.show()
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2),
            target: self,
            selector: "killNetworkDialog:",
            userInfo: nil,
            repeats: false)
    }
    
    func killNetworkDialog() {
        self.networkErrorDialog?.dismissWithClickedButtonIndex(0, animated: true)
        self.networkErrorDialog = nil
    }
    
    
    func onMainInitReturn(eventData : MainEventData) {
        if eventData.dialog != nil {
            eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
            eventData.dialog = nil
        }
        if eventData.returnStatus == "Error" {
            showTemporaryNetworkingError("Network Error", message: eventData.error!.reasonPhrase)
        } else if eventData.returnStatus == "Discover" {
            eventData.returnStatus = nil
            api.bgEvents.postEvent("Main:Discover:init", data: eventData)
        } else if eventData.returnStatus == "Master" {
            eventData.dialog = searchDialog("Welcome", message: eventData.master!.name!)
            api.bgEvents.postEvent("Main:Master:init", data: eventData)
        }
        
    }
    
    var discoverScreen : DiscoverScreen?
    func onDiscoverInitReturn(eventData : MainEventData) {
        if eventData.dialog != nil {
            eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
            eventData.dialog = nil
        }
        self.discoverScreen = DiscoverScreen(mainController: mainController!)
        navigationController.pushViewController(discoverScreen!, animated: true)
    }
    
    func onMasterInitReturn(eventData : MainEventData) {
        if eventData.dialog != nil {
            eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
            eventData.dialog = nil
        }
        if eventData.returnStatus == "Error" {
            showTemporaryNetworkingError("Network Problem", message: eventData.error!.reasonPhrase)
        } else {
            let master = eventData.master
            if (master != nil) {
                navigationController.popToRootViewControllerAnimated(true)
                let bapi = BuspassApi(httpClient: httpClient!, url: master!.apiUrl!, masterSlug: master!.slug!, appVersion: APP_VERSION, platformName: APP_PLATFORM)
                let masterController = MasterController(api: bapi, master: master!, mainController: mainController)
                let masterMapScreen = MasterMapScreen(masterController: masterController)
                navigationController.pushViewController(masterMapScreen, animated: true)
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.adiron.BusmeIPhone" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BusmeIPhone", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BusmeIPhone.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

