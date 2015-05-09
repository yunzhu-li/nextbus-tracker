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
import MapKit

class NTVCStopSelector: GAITrackedViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapPaths: MKMapView!
    @IBOutlet weak var tblStops: UITableView!
    
    // Data
    var stops: [NSDictionary] = [];
    var routePaths: [[NSDictionary]] = [];
    var routeExtent: [Double] = [];
    var routeTag: String = "";
    var routeTitle: String = "";
    
    // Map & location
    var plPaths: [MKPolyline] = [];
    var locationManager: CLLocationManager = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // GA
        self.screenName = NSStringFromClass(self.dynamicType);
        prepareMapView();
    }
    
    func prepareMapView() {
        
        // Request location permission
        locationManager.requestWhenInUseAuthorization();
        var authorizationStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus();
        if (authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse ||
            authorizationStatus == CLAuthorizationStatus.AuthorizedAlways) {
                mapPaths.showsUserLocation = true;
        }

        // Remove existing overlays
        self.mapPaths.removeOverlays(plPaths);
        
        // Prepare overlays
        for path in routePaths {
            var coordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(path.count);
            for (var i = 0; i < path.count; i++) {
                var point: NSDictionary = path[i];
                if let lat = point[NTMNextbus.NTMLatitude] as? NSString {
                    if let lon = point[NTMNextbus.NTMLongitude] as? NSString {
                        coordinates[i] = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue);
                    }
                }
            }
            
            plPaths.append(MKPolyline(coordinates: coordinates, count: path.count));
            coordinates.dealloc(path.count);
        }
        mapPaths.addOverlays(plPaths);
        
        // Set map view region
        var latMax = routeExtent[0];
        var latMin = routeExtent[1];
        var lonMax = routeExtent[2];
        var lonMin = routeExtent[3];
        
        var viewSpan: MKCoordinateSpan = MKCoordinateSpanMake((latMax - latMin) * 1.5, (lonMax - lonMin) * 1.5);
        var viewCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (latMin + latMax) / 2, longitude: (lonMin + lonMax) / 2);
        var r = MKCoordinateRegionMake(viewCenter, viewSpan);
        mapPaths.setRegion(r, animated: false);
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            var plRenderer = MKPolylineRenderer(overlay: overlay);
            plRenderer.strokeColor = UIColor(red: 0, green: 0.57, blue: 1, alpha: 0.7);
            plRenderer.lineWidth = 4;
            return plRenderer;
        }
        return nil;
    }
    
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
        
        // Pop view controller after operations
        var pop = true;
        
        if let stopTag = stops[indexPath.row][NTMNextbus.NTMKeyTag] as? String {
            if let stopTitle = stops[indexPath.row][NTMNextbus.NTMKeyTitle] as? String {
                let b = NTMNextbus.addStopToLocalStorage(NTMNextbus.NTMDefaultAgency, route: routeTag, routeTitle: routeTitle, direction: "loop", directionTitle: "Loop", stop: stopTag, stopTitle: stopTitle);
                
                if (!b) {
                    // Pop alert
                    var alert = UIAlertController(title: "Can't save stop", message: "Stop already saved.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    // Don't pop view controller
                    pop = false;
                }
            }
        }
        if (pop) {
            self.navigationController?.popToRootViewControllerAnimated(true);
        }
    }
}
