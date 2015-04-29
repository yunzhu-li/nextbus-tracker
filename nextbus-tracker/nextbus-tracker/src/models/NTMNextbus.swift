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

class NTMNextbus {
    static private var basicURL = "http://webservices.nextbus.com/service/publicXMLFeed";
    static let NTMDefaultAgency = "rutgers-newark";
    static let NTMKeyCommand    = "command";
    static let NTMKeyTitle      = "title";
    static let NTMKeyRouteTitle = "routeTitle";
    static let NTMKeyStopTitle  = "stopTitle";
    static let NTMKeyAgency     = "a";
    static let NTMKeyRoute      = "r";
    static let NTMKeyDirection  = "d";
    static let NTMKeyStop       = "s";
    static let NTMKeyMinutes    = "_minutes";
    
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
        
        FLHTTPUtils.sendAsynchronousRequest(basicURL, param_keys: param_keys, param_values: param_values, timeoutInterval: nil) { (urlResponse, data, error) -> Void in
            var d = XMLDictionaryParser.sharedInstance().dictionaryWithData(data);
            var result: [[NSDictionary]] = [];
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
                    }
                }
                dataHandler(result, NSError(domain: "", code: 0, userInfo: nil));
                return;
            }
            dataHandler(nil, NSError(domain: "", code: 1, userInfo: nil));
        }
    }
    
    static func getPredictionsForSingleStop(agency: String, route: String, direction: String, stop: String, dataHandler: (AnyObject?, NSError!) -> Void) -> Void {
        
        var param_keys: [String] = [],      param_values: [String] = [];
        param_keys.append(NTMKeyCommand);   param_values.append("predictions");
        param_keys.append(NTMKeyAgency);    param_values.append(agency);
        param_keys.append(NTMKeyRoute);     param_values.append(route);
        param_keys.append(NTMKeyDirection); param_values.append(direction);
        param_keys.append(NTMKeyStop);      param_values.append(stop);
        
        FLHTTPUtils.sendAsynchronousRequest(basicURL, param_keys: param_keys, param_values: param_values, timeoutInterval: nil) { (urlResponse, data, error) -> Void in
            
            //var dict = XMLDictionaryParser.sharedInstance().dictionaryWithString("<?xml version=\"1.0\" encoding=\"utf-8\" ?> <body copyright=\"All data copyright Rutgers Univ. Newark College Town Shuttle 2015.\"><predictions agencyTitle=\"Rutgers Univ. Newark College Town Shuttle\" routeTitle=\"Kearney/Harrison\" routeTag=\"kearney\" stopTitle=\"NJIT\" stopTag=\"njit\">  <direction title=\"Loop\">  <prediction epochTime=\"1430187911952\" seconds=\"480\" minutes=\"8\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4209\" block=\"201\" />  <prediction epochTime=\"1430189009954\" seconds=\"1578\" minutes=\"26\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"202\" />  <prediction epochTime=\"1430190138975\" seconds=\"2707\" minutes=\"45\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4209\" block=\"201\" />  <prediction epochTime=\"1430191338975\" seconds=\"3907\" minutes=\"65\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4187\" block=\"202\" />  <prediction epochTime=\"1430192538975\" seconds=\"5107\" minutes=\"85\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4209\" block=\"201\" />  </direction></predictions></body>");
            
            //var dict = XMLDictionaryParser.sharedInstance().dictionaryWithString("<?xml version=\"1.0\" encoding=\"utf-8\" ?> <body copyright=\"All data copyright Rutgers Univ. Newark College Town Shuttle 2015.\"><predictions agencyTitle=\"Rutgers Univ. Newark College Town Shuttle\" routeTitle=\"Kearney/Harrison\" routeTag=\"kearney\" stopTitle=\"NJIT\" stopTag=\"njit\">  <direction title=\"Loop\">  <prediction epochTime=\"1430192538975\" seconds=\"1214\" minutes=\"20\" isDeparture=\"false\" affectedByLayover=\"true\" dirTag=\"loop\" vehicle=\"4209\" block=\"201\" /></direction></predictions></body>");
            
            var result: [NSDictionary] = [];
            var dict = XMLDictionaryParser.sharedInstance().dictionaryWithData(data);
            if (dict != nil) {
                if let predictions = dict["predictions"] as? NSDictionary {
                    if let direction = predictions["direction"] as? NSDictionary {
                        if let prediction = direction["prediction"] as? NSArray {
                            for item in prediction {
                                if let pred = item as? NSDictionary {
                                    result.append(pred);
                                }
                            }
                        }
                        if let prediction = direction["prediction"] as? NSDictionary {
                            result.append(prediction);
                        }
                    }
                    dataHandler(result, NSError(domain: "", code: 0, userInfo: nil));
                    return;
                }
            }
            dataHandler([], NSError(domain: "", code: 1, userInfo: nil));
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
        
        FLLocalStorageUtils.writeObjectToUserDefaults("NTVCBookmarks", object: a);
    }
}
