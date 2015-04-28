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
    @IBOutlet weak var tblBookmarks: UITableView!
    let NTVCBookmarksLocalStorageKey = "NTVCBookmarks";
    
    var preditions: [Dictionary<String, String>] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGrayColor();
        self.navigationController?.navigationBar.translucent = false;
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ];
        
        //NTMNextbus.writeDebugData();
        refreshData();
    }
        
    func refreshData() {
        if let array = FLLocalStorageUtils.readObjectFromUserDefaults(NTVCBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            for dict in array {
                
                let agency: String     = dict[NTMNextbus.NTMKeyAgency] as String!;
                let route: String      = dict[NTMNextbus.NTMKeyRoute] as String!;
                let direction: String  = dict[NTMNextbus.NTMKeyDirection] as String!;
                let stop: String       = dict[NTMNextbus.NTMKeyStop] as String!;
                var minutes: String    = "";
                
                // Get minutes
                NTMNextbus.getPredictionsForSingleStop(agency, route: route, direction: direction, stop: stop) { (response, error) -> Void in
                    if (error.code == 0) {
                        let array = response as! [NSDictionary];
                        for item in array {
                            if let min = item["_minutes"] as? String {
                                minutes += min + " min | ";
                            }
                        }
                    }
                    
                    var prediction = dict;
                    prediction[NTMNextbus.NTMKeyMinutes] = minutes;
                    self.preditions.append(prediction);
                    
                    self.tblBookmarks.reloadData();
                }
            }
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preditions.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NTTblCellBookmarks = tblBookmarks.dequeueReusableCellWithIdentifier("tblCellBookmarks") as! NTTblCellBookmarks;
        
        cell.lblStop.text = preditions[indexPath.row][NTMNextbus.NTMKeyStop];
        cell.lblPredictions.text = preditions[indexPath.row][NTMNextbus.NTMKeyMinutes];
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

