//
//  This file is part of Nextbus Tracker.
//
//  Created by Yunzhu Li on 04/27/15.
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

class NTMNextbus {
    static private var baseURL            = "https://api.blupig.net/external/nextbus/service/publicXMLFeed"
    static let NTMBookmarksLocalStorageKey = "NTMBookmarks"
    
    // Fetch mode for getPredictionsOfBookmarkedStops
    enum NTMPredictionFetchMode {
        case Full       // Return full prediction data
        case Short      // Return at most 3 predictions
        case One        // Return at most 1 prediction
    }
    
    static let NTMDefaultAgency       = "rutgers"
    static let NTMDefaultAgencyTitle  = "Rutgers University"
    static let NTMKeyCommand          = "command"
    static let NTMKeyTitle            = "_title"
    static let NTMKeyTag              = "_tag"
    static let NTMKeyRouteTag         = "_routeTag"
    static let NTMKeyRouteTitle       = "routeTitle"
    static let NTMKeyStopTag          = "_stopTag"
    static let NTMKeyStopTitle        = "stopTitle"
    static let NTMKeyDirectionTag     = "_dirTag"
    static let NTMKeyAgency           = "a"
    static let NTMKeyRoute            = "r"
    static let NTMKeyDirection        = "d"
    static let NTMKeyStop             = "s"
    static let NTMKeyMinutes          = "_minutes"
    static let NTMLatitude            = "_lat"
    static let NTMLongitude           = "_lon"
    static let NTMLatitudeMax         = "_latMax"
    static let NTMLatitudeMin         = "_latMin"
    static let NTMLongitudeMax        = "_lonMax"
    static let NTMLongitudeMin        = "_lonMin"

    /* Get route configuration */
    static func getRouteConfig(agency: String, dataHandler: @escaping (Any?, String?) -> Void) -> Void {
        
        var param_keys: [String] = [], param_values: [String] = []
        param_keys.append(NTMKeyCommand); param_values.append("routeConfig")
        param_keys.append(NTMKeyAgency);  param_values.append(agency)
        
        // Show network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Begin request
        FLHTTPUtils.sendAsynchronousRequest(urlString: baseURL, param_keys: param_keys, param_values: param_values, timeoutInterval: FLHTTPUtils.FLDefaultTimeoutInterval) { (urlResponse, data, error) -> Void in
            
            // Hide network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            // Parse data
            if data != nil {
                if let dict = XMLDictionaryParser.sharedInstance().dictionary(with: data! as Data) {
                    dataHandler(dict, nil)
                    return
                }
            }
            dataHandler(nil, "Failed to fetch data")
        }
    }
    
    /* Get route list by routeConfig data */
    static func getRouteList(routeConfig: NSDictionary) -> [NSDictionary]? {
        // TODO: Filtering non-loop routes out for now
        let whiteListedRoutes = ["kearney", "penn", "pennexpr", "mdntpenn", "connect"]
        if let array = routeConfig["route"] as? [NSDictionary] {
            var result = [NSDictionary]()
            for _route in array {
                if _route[NTMKeyTag] is String && whiteListedRoutes.contains(_route[NTMKeyTag] as! String) {
                    result.append(_route)
                }
            }
            return result
        } else {
            return nil
        }
    }
    
    /* Get stop list by routeConfig data */
    static func getStopList(route: NSDictionary) -> [NSDictionary]? {
        if let array = route["stop"] as? [NSDictionary] {
            return array
        } else {
            return nil
        }
    }
    
    /* Get route extent (maximum and minimum coordinates) by routeConfig data */
    static func getRouteExtent(route: NSDictionary) -> [Double]? {
        var result: [Double] = []
        if let latMax = route[NTMLatitudeMax] as? String  { result.append((latMax as NSString).doubleValue) } else { return nil }
        if let latMin = route[NTMLatitudeMin] as? String  { result.append((latMin as NSString).doubleValue) } else { return nil }
        if let lonMax = route[NTMLongitudeMax] as? String { result.append((lonMax as NSString).doubleValue) } else { return nil }
        if let lonMin = route[NTMLongitudeMin] as? String { result.append((lonMin as NSString).doubleValue) } else { return nil }
        
        return result
    }
    
    /* Get path coordinates by routeConfig data */
    static func getPathCoordinates(route: NSDictionary) -> [[NSDictionary]]? {
        var result: [[NSDictionary]] = []
        
        // Extract paths
        if let ar_paths = route["path"] as? [NSDictionary] {
            // For each path
            for i in 0 ..< ar_paths.count {
                let path = ar_paths[i]
                var tmp_points: [NSDictionary] = []
                if let points = path["point"] as? [NSDictionary] {
                    tmp_points = points
                }
                result.append(tmp_points)
            }
            return result
        } else {
            return nil
        }
    }
    
    /* Prediction for multiple stops */
    static func getPredictionsForMultiStops(agency: String, routes: [String], directions: [String], stops: [String], dataHandler: @escaping (Any?, String?) -> Void) -> Void {
        
        assert(routes.count == stops.count && routes.count == directions.count, "The number of routes and directions and stops must be equal.")
        
        // Generate request parameters
        var param_keys: [String] = [], param_values: [String] = []
        param_keys.append(NTMKeyCommand); param_values.append("predictionsForMultiStops")
        param_keys.append(NTMKeyAgency);  param_values.append(agency)
        
        for i in 0 ..< routes.count {
            param_keys.append("stops")
            param_values.append(routes[i] + "|" + directions[i] + "|" + stops[i])
        }
        
        // Show network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Begin request
        FLHTTPUtils.sendAsynchronousRequest(urlString: baseURL, param_keys: param_keys, param_values: param_values, timeoutInterval: nil) { (urlResponse, data, error) -> Void in
            
            // Hide network activity indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            // Begin with pre-allocated array
            var result: [[NSDictionary]] = []
            for _ in 0 ..< routes.count {
                result.append([])
            }

            // Parse data
            if let dict = XMLDictionaryParser.sharedInstance().dictionary(with: data) {
                // Get "predictions" tags
                if let predictions = dict["predictions"] as? [[AnyHashable : Any]] {
                    for _predictions in predictions {
                        // Single "predictions" tag of one stop
                        var _p: [NSDictionary] = []
                        if let direction = _predictions["direction"] as? NSDictionary {
                            if let prediction = direction["prediction"] as? NSArray {
                                for item in prediction {
                                    if let pred = item as? NSDictionary {
                                        _p.append(pred)
                                    }
                                }
                            }
                            if let prediction = direction["prediction"] as? NSDictionary {
                                _p.append(prediction)
                            }
                        }

                        // Find the index
                        for i in 0 ..< routes.count {
                            if (_predictions[NTMKeyRouteTag] is String && _predictions[NTMKeyRouteTag] as! String == routes[i] &&
                                _predictions[NTMKeyStopTag] is String && _predictions[NTMKeyStopTag] as! String == stops[i]) {

                                result[i] = _p
                            }
                        }

                    }
                    dataHandler(result, nil)
                    return
                }
                
                // Only one stop (only one "predictions" tag)
                if let predictions = dict["predictions"] as? NSDictionary {
                    var _p: [NSDictionary] = []
                    if let direction = predictions["direction"] as? NSDictionary {
                        if let prediction = direction["prediction"] as? NSArray {
                            for item in prediction {
                                if let pred = item as? NSDictionary {
                                    _p.append(pred)
                                }
                            }
                        }
                        if let prediction = direction["prediction"] as? NSDictionary {
                            _p.append(prediction)
                        }
                        result[0] = _p
                    }
                }
                dataHandler(result, nil)
                return
            }
            dataHandler(nil, "Failed to fetch data")
        }
    }
    
    /* Get prediction data od bookmarked stops */
    static func getPredictionsOfBookmarkedStops(mode: NTMPredictionFetchMode, dataHandler: @escaping (Any?, String?) -> Void) {
        if var localBookmarks = FLLocalStorageUtils.readObjectFromUserDefaults(key: NTMNextbus.NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            
            // Check if no bookmarks
            if (localBookmarks.count == 0) {
                dataHandler(nil, "No bookmarks")
                return
            }
            
            // Generate request parameters
            var routes: [String] = [], directions: [String] = [], stops: [String] = []
            for i in 0 ..< localBookmarks.count {
                
                // Parameters for request
                routes.append(localBookmarks[i][NTMNextbus.NTMKeyRoute] as String!)
                directions.append(localBookmarks[i][NTMNextbus.NTMKeyDirection] as String!)
                stops.append(localBookmarks[i][NTMNextbus.NTMKeyStop] as String!)
            }
            
            // Get predictions
            NTMNextbus.getPredictionsForMultiStops(agency: NTMNextbus.NTMDefaultAgency, routes: routes, directions: directions, stops: stops) { (response, error) -> Void in
                
                if (error == nil) {
                    let responseArray = response as! [[NSDictionary]]
                    
                    // Check number of returned stop
                    if (responseArray.count != localBookmarks.count) {
                        
                        // Reply with bookmarks and empty preditions
                        for i in 0 ..< localBookmarks.count {
                            localBookmarks[i][NTMNextbus.NTMKeyMinutes] = ""
                        }
                        dataHandler(localBookmarks, nil)
                        return
                    }
                    
                    // Stops
                    for i in 0 ..< responseArray.count {
                        var prediction = responseArray[i]
                        var minutes: String = ""
                        
                        // Predictions
                        var count = prediction.count
                        if (mode == NTMPredictionFetchMode.Short) {
                            if (prediction.count > 3) {
                                count = 3
                            }
                        }
                        
                        // Iterate through every prediction value
                        for j in 0 ..< count {
                            if let min = prediction[j]["_minutes"] as? String {
                                
                                // For Apple Watch glance scene, return only one value
                                if (mode == NTMPredictionFetchMode.One) {
                                    minutes = min
                                    break
                                }
                                
                                if (j == 0 && j == count - 1) {
                                    minutes = "In " + min + " minutes"
                                } else if (j == 0) {
                                    minutes = "In " + min + ", "
                                } else if (j == count - 1) {
                                    minutes += min + " minutes"
                                } else {
                                    minutes += min + ", "
                                }
                            } else {
                                // Set empty value if no valid value fetched
                                minutes = ""
                            }
                        }
                        localBookmarks[i][NTMNextbus.NTMKeyMinutes] = minutes
                    }
                    
                } else {
                    // Didn't get data, set empty preditions for reply
                    for i in 0 ..< localBookmarks.count {
                        localBookmarks[i][NTMNextbus.NTMKeyMinutes] = ""
                    }
                }
                // Reply with data
                dataHandler(localBookmarks, nil)
                return
            }
        } else {
            // No locally storaged data
            dataHandler(nil, "No locally storaged data")
            return
        }
    }
    
    /* Add a stop to bookmarks and write to local storage */
    static func addStopToLocalStorage(agency: String, route: String, routeTitle: String, direction: String, directionTitle: String, stop: String, stopTitle: String) -> Bool {
        
        var dict: Dictionary<String, String> = Dictionary<String, String>()
        dict[NTMNextbus.NTMKeyAgency] = agency
        dict[NTMNextbus.NTMKeyRoute] = route
        dict[NTMNextbus.NTMKeyRouteTitle] = routeTitle
        dict[NTMNextbus.NTMKeyDirection] = direction
        dict[NTMNextbus.NTMKeyStop] = stop
        dict[NTMNextbus.NTMKeyStopTitle] = stopTitle
        
        var array: [Dictionary<String, String>] = []
        if var _array = FLLocalStorageUtils.readObjectFromUserDefaults(key: NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            
            // Check duplicate
            for _item in _array {
                if (_item[NTMNextbus.NTMKeyRoute] == route && _item[NTMNextbus.NTMKeyStop] == stop) {
                    return false
                }
            }
            
            // No duplicate
            _array.append(dict)
            array = _array
        } else {
            array.append(dict)
        }
        FLLocalStorageUtils.writeObjectToUserDefaults(key: NTMBookmarksLocalStorageKey, object: array)
        return true
    }
    
    /* Remove a stop from local storage */
    static func removeStopFromLocalStorage(index: Int) -> Bool {
        if var _array = FLLocalStorageUtils.readObjectFromUserDefaults(key: NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            if (index >= _array.count) {
                return false
            }
            _array.remove(at: index)
            FLLocalStorageUtils.writeObjectToUserDefaults(key: NTMBookmarksLocalStorageKey, object: _array)
            return true
        }
        return false
    }
    
    static func writeDebugData() {
        var d = Dictionary <String, Any>()
        var a: [Dictionary<String, Any>] = []
        
        d[NTMNextbus.NTMKeyAgency] = "rutgers"
        d[NTMNextbus.NTMKeyRoute] = "kearney"
        d[NTMNextbus.NTMKeyRouteTitle] = "Kearney/Harrison"
        d[NTMNextbus.NTMKeyDirection] = "loop"
        d[NTMNextbus.NTMKeyStop] = "njit"
        d[NTMNextbus.NTMKeyStopTitle] = "NJIT"
        
        a.append(d)
        
        d[NTMNextbus.NTMKeyAgency] = "rutgers"
        d[NTMNextbus.NTMKeyRoute] = "kearney"
        d[NTMNextbus.NTMKeyRouteTitle] = "Kearney/Harrison"
        d[NTMNextbus.NTMKeyDirection] = "loop"
        d[NTMNextbus.NTMKeyStop] = "harrpass"
        d[NTMNextbus.NTMKeyStopTitle] = "Harrison Ave & Passaic Ave"
        
        a.append(d)
        
        FLLocalStorageUtils.writeObjectToUserDefaults(key: NTMBookmarksLocalStorageKey, object: a)
    }
}

/* Debug data

//var dict = XMLDictionaryParser.sharedInstance().dictionaryWithString("<?xml version=\"1.0\" encoding=\"utf-8\" ?> <body copyright=\"All data copyright Rutgers Univ. Newark College Town Shuttle 2015.\"><predictions agencyTitle=\"Rutgers Univ. Newark College Town Shuttle\" routeTitle=\"Kearney/Harrison\" routeTag=\"kearney\" stopTitle=\"Harrison Ave &amp Passaic Ave\" stopTag=\"harrpass\">  <direction title=\"Loop\">  <prediction epochTime=\"1430259402212\" seconds=\"835\" minutes=\"13\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430261721215\" seconds=\"3154\" minutes=\"52\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430263868158\" seconds=\"5301\" minutes=\"88\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  </direction></predictions><predictions agencyTitle=\"Rutgers Univ. Newark College Town Shuttle\" routeTitle=\"Kearney/Harrison\" routeTag=\"kearney\" stopTitle=\"NJIT\" stopTag=\"njit\">  <direction title=\"Loop\">  <prediction epochTime=\"1430258964074\" seconds=\"397\" minutes=\"6\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430261283077\" seconds=\"2716\" minutes=\"45\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430263456522\" seconds=\"4889\" minutes=\"81\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  </direction></predictions></body>")

*/
