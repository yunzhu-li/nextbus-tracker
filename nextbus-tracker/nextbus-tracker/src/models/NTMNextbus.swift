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
    
    static private var basicURL            = "http://webservices.nextbus.com/service/publicXMLFeed";
    static let NTMBookmarksLocalStorageKey = "NTMBookmarks";
    enum NTMPredictionFetchMode {
        case Full
        case Short
        case One
    }
    
    static let NTMDefaultAgency       = "rutgers-newark";
    static let NTMDefaultAgencyTitle  = "Rutgers Univ. Newark College Town Shuttle";
    static let NTMKeyCommand          = "command";
    static let NTMKeyTitle            = "_title";
    static let NTMKeyTag              = "_tag";
    static let NTMKeyRouteTitle       = "routeTitle";
    static let NTMKeyStopTitle        = "stopTitle";
    static let NTMKeyAgency           = "a";
    static let NTMKeyRoute            = "r";
    static let NTMKeyDirection        = "d";
    static let NTMKeyStop             = "s";
    static let NTMKeyMinutes          = "_minutes";
    
    /* Get route configuration */
    static func getRouteConfig(agency: String, dataHandler: (AnyObject?, NSError!) -> Void) -> Void {
        
        var param_keys: [String] = [], param_values: [String] = [];
        param_keys.append(NTMKeyCommand); param_values.append("routeConfig");
        param_keys.append(NTMKeyAgency);  param_values.append(agency);
        
        // Begin request
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        FLHTTPUtils.sendAsynchronousRequest(basicURL, param_keys: param_keys, param_values: param_values, timeoutInterval: nil) { (urlResponse, data, error) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
            var dict = XMLDictionaryParser.sharedInstance().dictionaryWithData(data);
            if (dict != nil) {
                dataHandler(dict, NSError(domain: "", code: 0, userInfo: nil));
                return;
            }
            dataHandler(nil, NSError(domain: "", code: 1, userInfo: nil));
        }
    }
    
    /* Get route list by routeConfig data */
    static func getRouteList(routeConfig: NSDictionary) -> [NSDictionary]? {
        if let array = routeConfig["route"] as? [NSDictionary] {
            return array;
        } else {
            return nil;
        }
    }
    
    /* Get stop list by routeConfig data */
    static func getStopList(route: NSDictionary) -> [NSDictionary]? {
        if let array = route["stop"] as? [NSDictionary] {
            return array;
        } else {
            return nil;
        }
    }
    
    /* Prediction for multiple stops */
    static func getPredictionsForMultiStops(agency: String, routes: [String], directions: [String], stops: [String], dataHandler: (AnyObject?, NSError!) -> Void) -> Void {
        
        assert(routes.count == stops.count && routes.count == directions.count, "The number of routes and directions and stops must be equal.");
        
        var param_keys: [String] = [], param_values: [String] = [];
        param_keys.append(NTMKeyCommand); param_values.append("predictionsForMultiStops");
        param_keys.append(NTMKeyAgency);  param_values.append(agency);
        
        // Generate request parameters
        for (var i = 0; i < routes.count; i++) {
            param_keys.append("stops");
            param_values.append(routes[i] + "|" + directions[i] + "|" + stops[i]);
        }
        
        // Begin request
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        FLHTTPUtils.sendAsynchronousRequest(basicURL, param_keys: param_keys, param_values: param_values, timeoutInterval: nil) { (urlResponse, data, error) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
            var result: [[NSDictionary]] = [];
            
            //var dict = XMLDictionaryParser.sharedInstance().dictionaryWithString("<?xml version=\"1.0\" encoding=\"utf-8\" ?> <body copyright=\"All data copyright Rutgers Univ. Newark College Town Shuttle 2015.\"><predictions agencyTitle=\"Rutgers Univ. Newark College Town Shuttle\" routeTitle=\"Kearney/Harrison\" routeTag=\"kearney\" stopTitle=\"Harrison Ave &amp; Passaic Ave\" stopTag=\"harrpass\">  <direction title=\"Loop\">  <prediction epochTime=\"1430259402212\" seconds=\"835\" minutes=\"13\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430261721215\" seconds=\"3154\" minutes=\"52\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430263868158\" seconds=\"5301\" minutes=\"88\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  </direction></predictions><predictions agencyTitle=\"Rutgers Univ. Newark College Town Shuttle\" routeTitle=\"Kearney/Harrison\" routeTag=\"kearney\" stopTitle=\"NJIT\" stopTag=\"njit\">  <direction title=\"Loop\">  <prediction epochTime=\"1430258964074\" seconds=\"397\" minutes=\"6\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430261283077\" seconds=\"2716\" minutes=\"45\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  <prediction epochTime=\"1430263456522\" seconds=\"4889\" minutes=\"81\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"201\" />  </direction></predictions></body>");
            
            var dict = XMLDictionaryParser.sharedInstance().dictionaryWithData(data);
            if (dict != nil) {
                if let predictions = dict["predictions"] as? NSArray {
                    for _predictions in predictions {
                        // "predictions" tag of one stop
                        var _p: [NSDictionary] = [];
                        if let direction = _predictions["direction"] as? NSDictionary {
                            if let prediction = direction["prediction"] as? NSArray {
                                for item in prediction {
                                    if let pred = item as? NSDictionary {
                                        _p.append(pred);
                                    }
                                }
                            }
                            if let prediction = direction["prediction"] as? NSDictionary {
                                _p.append(prediction);
                            }
                        }
                        result.append(_p);
                    }
                    dataHandler(result, NSError(domain: "", code: 0, userInfo: nil));
                    return;
                }
                
                // Only one stop
                if let predictions = dict["predictions"] as? NSDictionary {
                    var _p: [NSDictionary] = [];
                    if let direction = predictions["direction"] as? NSDictionary {
                        if let prediction = direction["prediction"] as? NSArray {
                            for item in prediction {
                                if let pred = item as? NSDictionary {
                                    _p.append(pred);
                                }
                            }
                        }
                        if let prediction = direction["prediction"] as? NSDictionary {
                            _p.append(prediction);
                        }
                        result.append(_p);
                        dataHandler(result, NSError(domain: "", code: 0, userInfo: nil));
                        return;
                    }
                }
            }
            dataHandler(nil, NSError(domain: "", code: 1, userInfo: nil));
        }
    }
    
    /* Get prediction data od bookmarked stops */
    static func getPredictionsOfBookmarkedStops(mode: NTMPredictionFetchMode, dataHandler: (AnyObject?, NSError!) -> Void) {
        if var predictions = FLLocalStorageUtils.readObjectFromUserDefaults(NTMNextbus.NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            
            if (predictions.count == 0) {
                dataHandler(nil, NSError(domain: "", code: 1, userInfo: nil));
                return;
            }
            
            var routes: [String] = [], directions: [String] = [], stops: [String] = [];
            for (var i = 0; i < predictions.count; i++) {
                // Parameters for request
                routes.append(predictions[i][NTMNextbus.NTMKeyRoute] as String!);
                directions.append(predictions[i][NTMNextbus.NTMKeyDirection] as String!);
                stops.append(predictions[i][NTMNextbus.NTMKeyStop] as String!);
            }
            
            // Get predictions
            NTMNextbus.getPredictionsForMultiStops(NTMNextbus.NTMDefaultAgency, routes: routes, directions: directions, stops: stops) { (response, error) -> Void in
                
                if (error.code == 0) {
                    let responseArray = response as! [[NSDictionary]];
                    
                    // Prediction of stops
                    for (var i = 0; i < responseArray.count; i++) {
                        var prediction = responseArray[i];
                        var minutes: String = "";
                        
                        // Predictions
                        var count = prediction.count;
                        if (mode == NTMPredictionFetchMode.Short) {
                            count = 3;
                        }
                        for (var j = 0; j < count; j++) {
                            if let min = prediction[j]["_minutes"] as? String {
                                if (mode == NTMPredictionFetchMode.One) {
                                    minutes = min;
                                    break;
                                }
                                
                                if (j == 0 && j == count - 1) {
                                    minutes = "In " + min + " minutes";
                                } else if (j == 0) {
                                    minutes = "In " + min + ", ";
                                } else if (j == count - 1) {
                                    minutes += min + " minutes";
                                } else {
                                    minutes += min + ", ";
                                }
                            }
                        }
                        predictions[i][NTMNextbus.NTMKeyMinutes] = minutes;
                    }
                    dataHandler(predictions, NSError(domain: "", code: 0, userInfo: nil));
                    return;
                }
                dataHandler(nil, NSError(domain: "", code: 1, userInfo: nil));
            }
        }
    }
    
    /* Add a stop to bookmarks and write to local storage */
    static func addStopToLocalStorage(agency: String, route: String, routeTitle: String, direction: String, directionTitle: String, stop: String, stopTitle: String) -> Void {
        
        var dict: Dictionary<String, String> = Dictionary<String, String>();
        dict[NTMNextbus.NTMKeyAgency] = agency;
        dict[NTMNextbus.NTMKeyRoute] = route;
        dict[NTMNextbus.NTMKeyRouteTitle] = routeTitle;
        dict[NTMNextbus.NTMKeyDirection] = direction;
        dict[NTMNextbus.NTMKeyStop] = stop;
        dict[NTMNextbus.NTMKeyStopTitle] = stopTitle;
        
        var array: [Dictionary<String, String>] = [];
        if var _array = FLLocalStorageUtils.readObjectFromUserDefaults(NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            _array.append(dict);
            array = _array;
        } else {
            array.append(dict);
        }
        FLLocalStorageUtils.writeObjectToUserDefaults(NTMBookmarksLocalStorageKey, object: array);
    }
    
    /* Remove a stop from local storage */
    static func removeStopFromLocalStorage(index: Int) {
        if var _array = FLLocalStorageUtils.readObjectFromUserDefaults(NTMBookmarksLocalStorageKey) as? [Dictionary<String, String>] {
            if (index >= _array.count) {
                return;
            }
            _array.removeAtIndex(index);
            FLLocalStorageUtils.writeObjectToUserDefaults(NTMBookmarksLocalStorageKey, object: _array);
        }
    }
    
    static func writeDebugData() {
        var d = Dictionary <String, AnyObject>();
        var a: [Dictionary<String, AnyObject>] = [];
        
        d[NTMNextbus.NTMKeyAgency] = "rutgers-newark";
        d[NTMNextbus.NTMKeyRoute] = "kearney";
        d[NTMNextbus.NTMKeyRouteTitle] = "Kearney/Harrison";
        d[NTMNextbus.NTMKeyDirection] = "loop";
        d[NTMNextbus.NTMKeyStop] = "njit";
        d[NTMNextbus.NTMKeyStopTitle] = "NJIT";
        
        a.append(d);
        
        d[NTMNextbus.NTMKeyAgency] = "rutgers-newark";
        d[NTMNextbus.NTMKeyRoute] = "kearney";
        d[NTMNextbus.NTMKeyRouteTitle] = "Kearney/Harrison";
        d[NTMNextbus.NTMKeyDirection] = "loop";
        d[NTMNextbus.NTMKeyStop] = "harrpass";
        d[NTMNextbus.NTMKeyStopTitle] = "Harrison Ave & Passaic Ave";
        
        a.append(d);
        
        FLLocalStorageUtils.writeObjectToUserDefaults(NTMBookmarksLocalStorageKey, object: a);
    }
}
