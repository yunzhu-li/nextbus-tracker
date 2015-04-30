//
//  This file is part of Nextbus Tracker.
//
//  Created by Yunzhu Li on 04/23/15.
//  Copyright (c) 2015 Yunzhu Li.
//
//  Nextbus Tracker is free software: you can redistribute
//  it and/or modify it under the terms of the GNU General
//  Public License version 3 as published by the Free
//  Software Foundation.
//
//  Nextbus Tracker is distributed in the hope that it will
//  be useful, but WITHOUT ANY WARRANTY; without even the
//  implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. See the GNU General Public License
//  for more details.
//
//  You should have received a copy of the GNU General Public
//  License along with Nextbus Tracker.
//  If not, see http://www.gnu.org/licenses/.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?;
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // GA
        GAI.sharedInstance().trackUncaughtExceptions = true;
        GAI.sharedInstance().dispatchInterval = 12;
        GAI.sharedInstance().trackerWithTrackingId("UA-61812304-3");
        
        // Status bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent;
        
        #if arch(i386) || arch(x86_64)
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            NSLog("Document Path: %@", documentsPath)
        #endif
        
        return true
    }
    
    /* Handle requests from WitchKit extension */
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        if let _userInfo = userInfo as? [String : String] {
            if (_userInfo.indexForKey("command") == nil) {
                return;
            }
            
            var mode = NTMNextbus.NTMPredictionFetchMode.Short;
            switch _userInfo["command"]! {
            case "predictions_short":
                mode = NTMNextbus.NTMPredictionFetchMode.Short;
            case "predictions_one":
                mode = NTMNextbus.NTMPredictionFetchMode.One;
            default:
                mode = NTMNextbus.NTMPredictionFetchMode.Short;
            }
            
            NTMNextbus.getPredictionsOfBookmarkedStops(mode) { (data, error) -> Void in
                if (error.code == 0) {
                    if let predictions = data as? [Dictionary<String, String>] {
                        reply(["predictions" : predictions]);
                        return;
                    }
                }
                reply(["predictions" : [Dictionary<String, String>]()]);
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
    }
    
    
}
