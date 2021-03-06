// This source file is part of the https://github.com/ColdGrub1384/Pisth open source project
//
// Copyright (c) 2017 - 2018 Adrian Labbé
// Licensed under Apache License v2.0
//
// See https://raw.githubusercontent.com/ColdGrub1384/Pisth/master/LICENSE for license information

import UIKit

/// Split view controller used on the window.
class SplitViewController: UISplitViewController {
    
    /// App Navigation view controller.
    var navigationController_: UINavigationController!
    
    /// App Detail Navigation view controller.
    var detailNavigationController: UINavigationController!
    
    /// A detail view controller. If it's set, you must set `detailNavigationController`. This View controller will be displayed and `detailNavigationController` will be passed to `AppDelegate.shared`.
    var detailViewController: UIViewController?
    
    private var presentedBetaAlert = false
    
    /// Show given view controllers and pass them to `AppDelegate.shared`.
    func load() {
        preferredDisplayMode = .primaryHidden
        if let detailViewController = detailViewController {
            viewControllers = [detailViewController, navigationController_]
        } else {
            viewControllers = [detailNavigationController, navigationController_]
        }
    }
    
    /// Set display mode for opening a connection.
    func setDisplayMode() {
        if isCollapsed {
            preferredDisplayMode = .primaryHidden
        } else {
            preferredDisplayMode = .primaryOverlay
            if let action = displayModeButtonItem.action {
                UIApplication.shared.sendAction(action, to: displayModeButtonItem.target, from: nil, for: nil)
            }
        }
    }
    
    /// Toggle the master view.
    func toggleMasterView() {
        guard displayModeButtonItem.action != nil else {
            return
        }
        UIApplication.shared.sendAction(displayModeButtonItem.action!, to: displayModeButtonItem.target, from: nil, for: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .clear
        }
        
        // Setup Navigation Controller
        let bookmarksVC = BookmarksTableViewController()
        bookmarksVC.modalPresentationStyle = .overCurrentContext
        if #available(iOS 13.0, *) {
            bookmarksVC.tableView.backgroundColor = .clear
        } else {
            bookmarksVC.tableView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        }
        if #available(iOS 13.0, *) {
            bookmarksVC.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        } else {
            bookmarksVC.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
        let navigationController = UINavigationController(rootViewController: bookmarksVC)
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        
        // Setup Split view controller
        navigationController_ = UINavigationController(rootViewController: BookmarksTableViewController())
        detailNavigationController = navigationController
        if #available(iOS 11.0, *) {
            navigationController_.navigationBar.prefersLargeTitles = true
        }
        
        load()
        AppDelegate.shared.window?.rootViewController = UIViewController()
        AppDelegate.shared.navigationController = navigationController_
        
        // Setup window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.tintColor = UIApplication.shared.keyWindow?.tintColor
        if #available(iOS 13.0, *) { } else {
            window.backgroundColor = .white
        }
        window.rootViewController = ContentViewController.shared
        if #available(iOS 11.0, *) {
            if let tint = UIColor(named: "Purple") {
                
                window.tintColor = tint
                UISwitch.appearance().onTintColor = tint
            }
        } else {
            let tint = UIColor.purple
            window.tintColor = tint
            UISwitch.appearance().onTintColor = tint
        }
        window.makeKeyAndVisible()
        AppDelegate.shared.window = window
        
        AppDelegate.shared.splitViewController = self
        delegate = AppDelegate.shared
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        preferredDisplayMode = .primaryHidden
        
        let betaAlert = UIAlertController(title: "Thanks for using Pisth beta!", message: "Don't forget to report any issue you see.", preferredStyle: .alert)
        betaAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        if (Bundle.main.infoDictionary?["Is Beta"] as? String) == "YES" && !presentedBetaAlert {
            present(betaAlert, animated: true, completion: nil)
            presentedBetaAlert = true
        }
    }
}
