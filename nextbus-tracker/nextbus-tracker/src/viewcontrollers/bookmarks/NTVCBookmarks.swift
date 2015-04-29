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

class NTVCBookmarks: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UI
    @IBOutlet weak var tblBookmarks: UITableView!
    var tblRefreshControl: UIRefreshControl!
    
    // Data
    var preditions: [Dictionary<String, String>] = [];
    var initialReload = true;
    var tmAutoRefresh: NSTimer = NSTimer();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Configure navigation bar appearance
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0.57, blue: 1, alpha: 1);
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ];
        
        // Configure Refresh Control
        self.tblRefreshControl = UIRefreshControl();
        self.tblRefreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged);
        self.tblRefreshControl.tintColor = UIColor.whiteColor();
        self.tblBookmarks.addSubview(tblRefreshControl)
        
        //NTMNextbus.writeDebugData();
        refreshData();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        initialReload = true;
        refreshData();
        tmAutoRefresh = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "refreshData", userInfo: nil, repeats: true);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        tmAutoRefresh.invalidate();
    }
    
    @IBAction func btnAddAct(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("PushToRouteSelector", sender: self);
    }
    
    func refreshData() {
        self.preditions = [];
        if let array = FLLocalStorageUtils.readObjectFromUserDefaults(NTMNextbus.NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            
            var routes: [String] = [], directions: [String] = [], stops: [String] = [];
            for (var i = 0; i < array.count; i++) {
                
                var prediction = array[i];
                prediction[NTMNextbus.NTMKeyMinutes] = "Getting prediction data...";
                self.preditions.append(prediction);
                
                // Parameters for request
                routes.append(array[i][NTMNextbus.NTMKeyRoute] as String!);
                directions.append(array[i][NTMNextbus.NTMKeyDirection] as String!);
                stops.append(array[i][NTMNextbus.NTMKeyStop] as String!);
            }
            
            if (initialReload) {
                initialReload = false;
                self.tblBookmarks.reloadData();
            }
            
            // Get predictions
            NTMNextbus.getPredictionsForMultiStops(NTMNextbus.NTMDefaultAgency, routes: routes, directions: directions, stops: stops) { (response, error) -> Void in
                
                self.tblRefreshControl.endRefreshing();
                if (error.code == 0) {
                    let array = response as! [[NSDictionary]];
                    
                    // Prediction of stops
                    for (var i = 0; i < array.count; i++) {
                        var prediction = array[i];
                        var minutes: String = "";
                        
                        // Predictions
                        for (var j = 0; j < prediction.count; j++) {
                            if let min = prediction[j]["_minutes"] as? String {
                                if (j == 0 && j == prediction.count - 1) {
                                    minutes = "In " + min + " minutes";
                                } else if (j == 0) {
                                    minutes = "In " + min + ", ";
                                } else if (j == prediction.count - 1) {
                                    minutes += min + " minutes";
                                } else {
                                    minutes += min + ", ";
                                }
                            }
                        }
                        self.preditions[i][NTMNextbus.NTMKeyMinutes] = minutes;
                    }
                } else {
                    for (var i = 0; i < array.count; i++) {
                        self.preditions[i][NTMNextbus.NTMKeyMinutes] = "";
                    }
                }
                self.tblBookmarks.reloadData();
            }
        } else {
            self.tblRefreshControl.endRefreshing();
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preditions.count + 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == preditions.count) {
            let cell: UITableViewCell = tblBookmarks.dequeueReusableCellWithIdentifier("tblCellBookmarksNew") as! UITableViewCell;
            return cell;
        }
        
        let cell: NTTblCellBookmarks = tblBookmarks.dequeueReusableCellWithIdentifier("tblCellBookmarks") as! NTTblCellBookmarks;
        
        cell.lblStop.text = preditions[indexPath.row][NTMNextbus.NTMKeyStopTitle];
        cell.lblRoute.text = preditions[indexPath.row][NTMNextbus.NTMKeyRouteTitle];
        
        var _p_str: String = preditions[indexPath.row][NTMNextbus.NTMKeyMinutes]!;
        if (_p_str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
            cell.lblPredictions.text = "No predictions available.";
        } else {
            cell.lblPredictions.text = _p_str;
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == preditions.count) {
            self.btnAddAct(UIBarButtonItem());
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.row < preditions.count) {
            return true;
        }
        return false;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        preditions.removeAtIndex(indexPath.row);
        NTMNextbus.removeStopFromLocalStorage(indexPath.row);
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic);
    }
}
