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

class NTVCRouteSelector: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblRoutes: UITableView!
    @IBOutlet weak var lblStatus: UILabel!
    
    var routes: [NSDictionary] = []
    var stopsForSelector: [NSDictionary] = []
    var pathsForSelector: [[NSDictionary]] = []
    var routeExtentForSelector: [Double] = []
    var routeTagForSelector = ""
    var routeTitleForSelector = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        self.tblRoutes.isHidden = true
        
        // Data
        NTMNextbus.getRouteConfig(agency: NTMNextbus.NTMDefaultAgency) { (result, error) -> Void in
            if error != nil {
                self.lblStatus.text = error
            }

            if let _result = result as? NSDictionary {
                let _routes = NTMNextbus.getRouteList(routeConfig: _result)
                if (_routes != nil) {
                    self.routes = _routes!
                    self.tblRoutes.reloadData()
                    self.tblRoutes.isHidden = false
                    self.lblStatus.isHidden = true
                } else {
                    self.lblStatus.text = "No routes returned from server"
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PushToStopSelector") {
            let vc: NTVCStopSelector = segue.destination as! NTVCStopSelector
            vc.stops = stopsForSelector
            vc.routePaths = pathsForSelector
            vc.routeExtent = routeExtentForSelector
            vc.routeTag = routeTagForSelector
            vc.routeTitle = routeTitleForSelector
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NTTblCellRoutes = tblRoutes.dequeueReusableCell(withIdentifier: "tblCellRoutes") as! NTTblCellRoutes
        
        // Configure cell display
        if let routeTitle = routes[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
            cell.lblRoute.text = routeTitle
            let stops = NTMNextbus.getStopList(route: routes[indexPath.row])
            if (stops != nil) {
                cell.lblRouteInfo.text = String(stops!.count) + " stops"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblRoutes.deselectRow(at: indexPath, animated: true)
        let stops = NTMNextbus.getStopList(route: routes[indexPath.row])
        
        if (stops != nil) {
            stopsForSelector = stops!
            if let routeTag = routes[indexPath.row][NTMNextbus.NTMKeyTag] as? String {
                if let routeTitle = routes[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
                    
                    let pathCoordinates = NTMNextbus.getPathCoordinates(route: routes[indexPath.row])
                    if (pathCoordinates != nil) {
                        pathsForSelector = pathCoordinates!
                    } else {
                        return
                    }
                    
                    let routeExtent = NTMNextbus.getRouteExtent(route: routes[indexPath.row])
                    if (routeExtent != nil && routeExtent?.count == 4) {
                        routeExtentForSelector = routeExtent!
                    } else {
                        return
                    }
                    
                    routeTagForSelector = routeTag
                    routeTitleForSelector = routeTitle
                    self.performSegue(withIdentifier: "PushToStopSelector", sender: self)
                }
            }
        }
    }
}
