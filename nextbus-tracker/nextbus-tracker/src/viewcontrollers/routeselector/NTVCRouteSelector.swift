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

class NTVCRouteSelector: GAITrackedViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblRoutes: UITableView!
    @IBOutlet weak var lblStatus: UILabel!
    
    var routes: [NSDictionary] = [];
    var stopsForSelector: [NSDictionary] = [];
    var pathsForSelector: [[NSDictionary]] = [];
    var routeExtentForSelector: [Double] = [];
    var routeTagForSelector = "";
    var routeTitleForSelector = "";
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // GA
        self.screenName = NSStringFromClass(self.dynamicType);
                
        // UI
        self.tblRoutes.hidden = true;
        
        // Data
        NTMNextbus.getRouteConfig(NTMNextbus.NTMDefaultAgency) { (result, error) -> Void in
            if (error.code != 0) {
                self.lblStatus.text = "Failed to get route data";
            }
            
            if let _result = result as? NSDictionary {
                let _routes = NTMNextbus.getRouteList(_result);
                if (_routes != nil) {
                    self.routes = _routes!;
                    self.tblRoutes.reloadData();
                    self.tblRoutes.hidden = false;
                    self.lblStatus.hidden = true;
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "PushToStopSelector") {
            let vc: NTVCStopSelector = segue.destinationViewController as! NTVCStopSelector;
            vc.stops = stopsForSelector;
            vc.routePaths = pathsForSelector;
            vc.routeExtent = routeExtentForSelector;
            vc.routeTag = routeTagForSelector;
            vc.routeTitle = routeTitleForSelector;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: NTTblCellRoutes = tblRoutes.dequeueReusableCellWithIdentifier("tblCellRoutes") as! NTTblCellRoutes;
        
        // Configure cell display
        if let routeTitle = routes[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
            cell.lblRoute.text = routeTitle;
            var stops = NTMNextbus.getStopList(routes[indexPath.row]);
            if (stops != nil) {
                cell.lblRouteInfo.text = String(stops!.count) + " stops";
            }
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tblRoutes.deselectRowAtIndexPath(indexPath, animated: true);
        var stops = NTMNextbus.getStopList(routes[indexPath.row]);
        
        if (stops != nil) {
            stopsForSelector = stops!;
            if let routeTag = routes[indexPath.row][NTMNextbus.NTMKeyTag] as? String {
                if let routeTitle = routes[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
                    
                    let pathCoordinates = NTMNextbus.getPathCoordinates(routes[indexPath.row]);
                    if (pathCoordinates != nil) {
                        pathsForSelector = pathCoordinates!;
                    } else {
                        return;
                    }
                    
                    let routeExtent = NTMNextbus.getRouteExtent(routes[indexPath.row]);
                    if (routeExtent != nil && routeExtent?.count == 4) {
                        routeExtentForSelector = routeExtent!;
                    } else {
                        return;
                    }
                    
                    routeTagForSelector = routeTag;
                    routeTitleForSelector = routeTitle;
                    self.performSegueWithIdentifier("PushToStopSelector", sender: self);
                }
            }
        }
    }
}
