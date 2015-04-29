//
//  This file is part of Nextbus Tracker.
//
//  Created by Yunzhu Li on 04/28/15.
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

import Foundation
import UIKit

class NTVCStopSelector: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblStops: UITableView!
    
    var stops: [NSDictionary] = [];
    var routeTag: String = "";
    var routeTitle: String = "";
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: NTTblCellStops = tblStops.dequeueReusableCellWithIdentifier("tblCellStops") as! NTTblCellStops;
        
        // Configure cell display
        if let stopTitle = stops[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
            cell.lblStopTitle.text = stopTitle;
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tblStops.deselectRowAtIndexPath(indexPath, animated: true);
        
        if let stopTag = stops[indexPath.row][NTMNextbus.NTMKeyTag] as? String {
            if let stopTitle = stops[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
                NTMNextbus.addStopToLocalStorage(NTMNextbus.NTMDefaultAgency, route: routeTag, routeTitle: routeTitle, direction: "loop", directionTitle: "Loop", stop: stopTag, stopTitle: stopTitle);
            }
        }
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
}
