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
import CoreLocation

class NTVCBookmarks: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UI
    @IBOutlet weak var tblBookmarks: UITableView!
    var tblRefreshControl: UIRefreshControl!
    
    // Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    
    // Data
    var preditions: [Dictionary<String, String>] = []
    var initialReload = true
    var tmAutoRefresh: Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request location permission
        locationManager.requestWhenInUseAuthorization()
        
        // Configure navigation bar appearance
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0.57, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.foregroundColor : UIColor.white ]
        
        // Configure Refresh Control
        self.tblRefreshControl = UIRefreshControl()
        self.tblRefreshControl.addTarget(self, action: #selector(NTVCBookmarks.refreshData), for: UIControlEvents.valueChanged)
        self.tblRefreshControl.tintColor = UIColor.white
        self.tblBookmarks.addSubview(tblRefreshControl)
        
        //NTMNextbus.writeDebugData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialReload = true
        refreshData()
        self.enableRefreshTimer(enabled: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.enableRefreshTimer(enabled: false)
    }
    
    @IBAction func btnAddAct(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "PushToRouteSelector", sender: self)
    }
    
    func enableRefreshTimer(enabled: Bool) {
        tmAutoRefresh.invalidate()
        if (enabled) {
            tmAutoRefresh.invalidate()
            tmAutoRefresh = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(NTVCBookmarks.refreshData), userInfo: nil, repeats: true)
        }
    }

    @objc func refreshData() {
        self.preditions = []
        if let array = FLLocalStorageUtils.readObjectFromUserDefaults(key: NTMNextbus.NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            
            var routes: [String] = [], directions: [String] = [], stops: [String] = []
            for i in 0 ..< array.count {
                
                var prediction = array[i]
                prediction[NTMNextbus.NTMKeyMinutes] = "Refreshing..."
                self.preditions.append(prediction)
                
                // Parameters for request
                routes.append(array[i][NTMNextbus.NTMKeyRoute] as String!)
                directions.append(array[i][NTMNextbus.NTMKeyDirection] as String!)
                stops.append(array[i][NTMNextbus.NTMKeyStop] as String!)
            }
            
            // Show "Refreshing..." in cells
            self.tblBookmarks.reloadData()
            
            // Get predictions
            NTMNextbus.getPredictionsOfBookmarkedStops(mode: NTMNextbus.NTMPredictionFetchMode.Full) { (data, error) -> Void in
                
                if let _data = data as? [Dictionary<String, String>] {
                    self.preditions = _data
                }
                self.tblBookmarks.reloadData()
                self.tblRefreshControl.endRefreshing()
            }
        } else {
            self.tblRefreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preditions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == preditions.count) {
            return tblBookmarks.dequeueReusableCell(withIdentifier: "tblCellBookmarksNew")!
        }
        
        let cell: NTTblCellBookmarks = tblBookmarks.dequeueReusableCell(withIdentifier: "tblCellBookmarks") as! NTTblCellBookmarks
        
        cell.lblStop.text = preditions[indexPath.row][NTMNextbus.NTMKeyStopTitle]
        cell.lblRoute.text = preditions[indexPath.row][NTMNextbus.NTMKeyRouteTitle]
        cell.lblPredictions.text = "No predictions available."
        if (preditions[indexPath.row].index(forKey: NTMNextbus.NTMKeyMinutes) != nil) {
            let _p_str: String = preditions[indexPath.row][NTMNextbus.NTMKeyMinutes]!
            if (_p_str.lengthOfBytes(using: String.Encoding.utf8) != 0) {
                cell.lblPredictions.text = _p_str
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == preditions.count) {
            self.btnAddAct(UIBarButtonItem())
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row < preditions.count) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.enableRefreshTimer(enabled: false)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.enableRefreshTimer(enabled: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        preditions.remove(at: indexPath.row)
        _ = NTMNextbus.removeStopFromLocalStorage(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
}
