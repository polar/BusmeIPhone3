//
//  AppDelegate.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

let INITIAL_URL = "http://busme-apis.herokuapp.com/apis/d1/get"
//let INITIAL_URL = "http://polars-macbook-air.local:3002/apis/d1/get"
let APP_PLATFORM = "iOS"

class Toast : UIResponder, UIAlertViewDelegate {
    var dialog : UIAlertView?
    var duration : Int = 2

    init(title: String, message: String, duration: Int) {
        self.duration = duration
        super.init()
        self.dialog = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
    }
    
    func show() {
        dialog?.show()
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(duration),
            target: self,
            selector: "dismissDialog",
            userInfo: nil,
            repeats: false)
    }
    
    func dismissDialog() {
        dialog?.dismissWithClickedButtonIndex(0, animated: true)
    }
}

class ErrorDialogRestartOnCancel : UIResponder, UIAlertViewDelegate {
    var dialog : UIAlertView
    var duration : Int = 2
    var restartDelay : Int = 2
    
    init(dialog : UIAlertView, duration : Int) {
        self.dialog = dialog
        self.duration = duration
        super.init()
        self.dialog.delegate = self
    }
    
    func show() {
        dialog.show()
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(duration),
            target: self,
            selector: "dismissDialog",
            userInfo: nil,
            repeats: false)
    }
    
    func dismissDialog() {
        dialog.dismissWithClickedButtonIndex(0, animated: true)
    }
    
    var completion : (() -> Void)?
    
    func setOnCancel(restartDelay: Int, completion: () -> Void) {
        self.restartDelay = restartDelay
        self.completion = completion
    }
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if (completion != nil) {
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(restartDelay),
                    target: self,
                    selector: "restart",
                    userInfo: nil,
                    repeats: false)
            }
        }
    }
    
    func restart() {
        if completion != nil {
            completion!()
        }
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
    
    var eventsController : EventsController = EventsController()
    
    
    var discoverScreen : DiscoverScreen?
    var masterMapScreen : MasterMapScreen?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        
        var httpQ : dispatch_queue_t = dispatch_queue_create("http", DISPATCH_QUEUE_SERIAL);
    
        self.httpClient = HttpClient(queue: httpQ)
        self.api = DiscoverApiVersion1(httpClient: httpClient!, initialUrl: INITIAL_URL)
        self.mainController = MainController(configurator: configurator, discoverApi: api)
        
        registerForEvents()
        
        contactBusServer()
        return true
    }
    
    func contactBusServer() {
        let eventData = MainEventData()
        eventData.dialog = searchDialog("Contacting Bus Server", message: "")
        eventData.dialog!.show()
        api.bgEvents.postEvent("Main:init", data: eventData)
    }
    
    func registerForEvents() {
        eventsController.register(api)
        api.uiEvents.registerForEvent("Main:Init:return", listener: self)
        api.uiEvents.registerForEvent("Main:Discover:Init:return", listener: self)
        api.uiEvents.registerForEvent("Main:Discover:return", listener: self)
        api.uiEvents.registerForEvent("Main:Master:Init:return", listener: self)
        api.uiEvents.registerForEvent("Main:Master:return", listener: self)
    }
    
    func registerForMasterEvents(api : BuspassApi) {
        api.uiEvents.registerForEvent("Master:Init:return", listener: self)
        api.uiEvents.registerForEvent("JourneySyncProgress", listener: self)
        api.uiEvents.registerForEvent("Master:Reload:return", listener: self)
        api.uiEvents.registerForEvent("StopTimers", listener: self)
    }
    
    func unregisterForMasterEvents(api : BuspassApi) {
        api.uiEvents.unregisterForEvent("Master:Init:return", listener: self)
        api.uiEvents.unregisterForEvent("JourneySyncProgress", listener: self)
        api.uiEvents.unregisterForEvent("Master:Reload:return", listener: self)
        api.uiEvents.unregisterForEvent("StopTimers", listener: self)
    }
    
    func searchDialog(title : String, message : String) -> UIAlertView {
        let dialog =  UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        return dialog
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if ("Main:Init:return" == eventName) {
            let eventData = event.eventData as? MainEventData
            onMainInitReturn(eventData!)
        } else if ("Main:Discover:Init:return" == eventName) {
            let eventData = event.eventData as? MainEventData
            onDiscoverInitReturn(eventData!)
        } else if ("Main:Discover:return" == eventName) {
            let eventData = event.eventData as? MainEventData
            onDiscoverReturn(eventData!)
        } else if ("Main:Master:Init:return" == eventName) {
            let eventData = event.eventData as? MainEventData
            onMainMasterInitReturn(eventData!)
        } else if ("Master:Init:return" == eventName) {
            let eventData = event.eventData as? MasterEventData
            onMasterInitReturn(eventData!)
        } else if ("Master:Reload:return" == eventName) {
            onMasterReloadReturn(event.eventData as MasterEventData!)
        } else if ("StopTimers" == eventName) {
            onStopTimers(event.eventData as MainEventData!)
        }
    }
    
    func showTemporaryNetworkingError(title: String, message: String, completion: () -> Void) {
        let networkErrorDialog = UIAlertView(title: title,
            message: message,
            delegate: self,
            cancelButtonTitle: "OK"
        )
        let errorDialog = ErrorDialogRestartOnCancel(dialog: networkErrorDialog, duration: 2)
        errorDialog.setOnCancel(10, completion)
        errorDialog.show()
    }
    
    func onMainInitReturn(eventData : MainEventData) {
        if eventData.dialog != nil {
            eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
            eventData.dialog = nil
        }
        if eventData.returnStatus == "Error" {
            showTemporaryNetworkingError("Network Error",
                message: eventData.error!.reasonPhrase, completion: {
                    self.contactBusServer()
            })
        } else if eventData.returnStatus == "Discover" {
            eventData.returnStatus = nil
            api.bgEvents.postEvent("Main:Discover:init", data: eventData)
        } else if eventData.returnStatus == "Master" {
            doMasterInit(eventData.master!)
        }
        
    }
    
    func doMasterInit(master : Master) {
        let masterApi = BuspassApi(httpClient: httpClient!, url: master.apiUrl!, masterSlug: master.slug!, appVersion: APP_VERSION, platformName: APP_PLATFORM)
        eventsController.register(masterApi)
        // Initialize the MainController with the Master, set up a MasterController
        let evd = MainEventData(masterApi : masterApi, master: master)
        api.bgEvents.postEvent("Main:Master:init", data: evd)
    }
    
    func onDiscoverInitReturn(eventData : MainEventData) {
        if eventData.dialog != nil {
            eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
            eventData.dialog = nil
        }
        self.discoverScreen = DiscoverScreen(mainController: mainController!)
        navigationController?.popViewControllerAnimated(false)
        self.navigationController = UINavigationController(rootViewController: discoverScreen!)
        window!.rootViewController = navigationController

    }
    
    // The Discover Screen has selected a master, maybe.
    func onDiscoverReturn(eventData : MainEventData) {
        if eventData.error == nil {
            if eventData.master != nil {
                doMasterInit(eventData.master!)
            } else {
                if (BLog.WARN) { BLog.logger.warn("No master selected") }
            }
        } else {
            if (BLog.WARN) { BLog.logger.warn("Error \(eventData.error!.reasonPhrase)") }
        }
    }
    
    // The MasterController has been set up. Assocate the MasterScreen
    func onMainMasterInitReturn(eventData : MainEventData) {
        if eventData.dialog != nil {
            eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
            eventData.dialog = nil
        }
        let master = eventData.master!
        if eventData.oldController != nil {
            eventsController.unregister(eventData.oldController!.api)
        }
        
        registerForMasterEvents(mainController!.masterController!.api)
        
        self.masterMapScreen = MasterMapScreen()
        masterMapScreen!.setMasterController(mainController!.masterController!)
        
        navigationController?.popViewControllerAnimated(false)
        self.navigationController = UINavigationController(rootViewController: masterMapScreen!)
        window!.rootViewController = navigationController
        
        let dialog = UIAlertView(title: "Welcome to \(master.name!)", message: "", delegate: nil, cancelButtonTitle: nil)
        dialog.show()
        let evd = MasterEventData(dialog: dialog)
        mainController!.masterController!.api.bgEvents.postEvent("Master:init", data: evd)
    }
    
    func onMasterInitReturn(eventData : MasterEventData) {
        if eventData.error != nil {
            if eventData.getTries < 2 {
                Toast(title: "Error", message: eventData.error!.reasonPhrase, duration: 2)
                eventData.error = nil
                eventData.returnStatus = nil
                eventData.getTries += 1
                mainController!.masterController!.api.bgEvents.postEvent("Master:init", data: eventData)
            } else {
                if eventData.dialog != nil {
                    eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
                    eventData.dialog = nil
                }        // Set up timers.

                Toast(title: "Giving Up", message: eventData.error!.reasonPhrase, duration: 2)
            }
        } else {
            if eventData.dialog != nil {
                eventData.dialog!.dismissWithClickedButtonIndex(0, animated: true)
                eventData.dialog = nil
            }        // Set up timers.
            self.bannerTimer = BannerTimer(masterController: mainController!.masterController!, interval: 10)
            self.updateTimer = UpdateTimer(masterController: mainController!.masterController!)
            self.syncTimer = JourneySyncTimer(masterController: mainController!.masterController!)
            startTimers()

            // Testing
            mainController!.masterController!.api.lastKnownLocation = CLLocationCoordinate2D(latitude: mainController!.masterController!.master.lat!, longitude: mainController!.masterController!.master.lon!)
        }
    }
    
    // Timers
    
    var bannerTimer : BannerTimer?
    var updateTimer : UpdateTimer?
    var syncTimer : JourneySyncTimer?
    var timersRunning : Bool = false
    func startTimers() {
        if !timersRunning {
            timersRunning = true
            bannerTimer?.start()
            updateTimer?.start(false)
            syncTimer?.start(true)
        }
    }
    func stopTimers() {
        bannerTimer?.stop()
        updateTimer?.stop()
        syncTimer?.stop()
        timersRunning = false
    }
    
    func onStopTimers(eventData : MainEventData) {
        stopTimers()
    }
    
    func onMasterReloadReturn(eventData : MasterEventData) {
        startTimers()
    }
    
    func storeMaster() {
        if mainController?.masterController != nil {
            mainController?.masterController?.api.bgEvents.postEvent("Master:store", data: MasterEventData())
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        stopTimers()
        storeMaster()
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
        if (mainController?.masterController != nil) {
             startTimers()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        if (mainController?.masterController != nil) {
            stopTimers()
        }
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

