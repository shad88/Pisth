// This source file is part of the https://github.com/ColdGrub1384/Pisth open source project
//
// Copyright (c) 2017 - 2018 Adrian Labbé
// Licensed under Apache License v2.0
//
// See https://raw.githubusercontent.com/ColdGrub1384/Pisth/master/LICENSE for license information

import UIKit
import CoreData
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DirectoryTableViewControllerDelegate, BookmarksTableViewControllerDelegate {

    static var shared: AppDelegate!

    var window: UIWindow?
    var navigationController = UINavigationController()
    var directoryTableViewController: DirectoryTableViewController?
    var openedFile: URL?
    var coreDataContext: NSManagedObjectContext {
        return AppDelegate.shared.persistentContainer.viewContext
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIMenuController.shared.menuItems = [UIMenuItem(title: "Move", action: #selector(FileTableViewCell.moveFile(_:)))]
        UIMenuController.shared.update()
        
        AppDelegate.shared = self
        
        // Setup Navigation Controller
        let bookmarksVC = BookmarksTableViewController()
        navigationController = UINavigationController(rootViewController: bookmarksVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.prefersLargeTitles = true
        
        // Setup window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9214899206650515~2846344793")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.absoluteString.hasPrefix("file://") { // Upload file
            self.openedFile = url
            let bookmarksVC = BookmarksTableViewController()
            let navVC = UINavigationController(rootViewController: bookmarksVC)
            navVC.navigationBar.barStyle = .black
            navVC.navigationBar.isTranslucent = true
            navVC.navigationBar.prefersLargeTitles = true
            
            navigationController.present(navVC, animated: true, completion: {
                bookmarksVC.delegate = self
                bookmarksVC.navigationItem.largeTitleDisplayMode = .never
                bookmarksVC.navigationItem.setLeftBarButtonItems([], animated: true)
                bookmarksVC.navigationItem.setRightBarButtonItems([UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))], animated: true)
                bookmarksVC.navigationItem.prompt = "Select connection where upload file"
            })
        }
        
        return false
    }
    
    @objc func uploadFile() {
        if let directoryTableViewController = directoryTableViewController {
            if let file = openedFile {
                directoryTableViewController.localDirectoryTableViewController(LocalDirectoryTableViewController(directory: FileManager.default.documents), didOpenFile: file)
            }
        }
    }
    
    @objc func close() {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.dismiss(animated: true, completion: {
                self.openedFile = nil
                self.directoryTableViewController = nil
            })
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Pisth")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - DirectoryTableViewControllerDelegate
    func directoryTableViewController(_ directoryTableViewController: DirectoryTableViewController, didOpenDirectory directory: String) {
        directoryTableViewController.navigationItem.prompt = "Select folder where upload file"
        directoryTableViewController.delegate = self
        directoryTableViewController.closeAfterSending = true
        self.directoryTableViewController = directoryTableViewController
        UIApplication.shared.keyWindow?.rootViewController?.navigationController?.pushViewController(directoryTableViewController, animated: true) {
            directoryTableViewController.navigationItem.rightBarButtonItems?.remove(at: 1)
        }
    }
    
    // MARK: - BookmarksTableViewControllerDelegate
    func bookmarksTableViewController(_ bookmarksTableViewController: BookmarksTableViewController, didOpenConnection: RemoteConnection, inDirectoryTableViewController directoryTableViewController: DirectoryTableViewController) {
        
        directoryTableViewController.navigationItem.prompt = "Select folder where upload file"
        directoryTableViewController.delegate = self
        directoryTableViewController.closeAfterSending = true
        self.directoryTableViewController = directoryTableViewController
        bookmarksTableViewController.navigationController?.pushViewController(directoryTableViewController, animated: true) {
            directoryTableViewController.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "cloud-upload"), style: .done, target: self, action: #selector(self.uploadFile))]
        }
    }
}

