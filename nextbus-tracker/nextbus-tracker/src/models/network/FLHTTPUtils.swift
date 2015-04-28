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

class FLHTTPUtils {
    static private var FLDefaultTimeoutInterval: NSTimeInterval = 5;
    
    /* PercentEscape Encoder */
    static func encodeToPercentEscapeString(input: String) -> String? {
        return input.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding);
    }
    
    /* Send asynchronous request */
    static func sendAsynchronousRequest(urlString: String, param_keys: [String]?, param_values: [String]?, timeoutInterval: NSTimeInterval?, completionHandler: (NSURLResponse!, NSData!, NSError!) -> Void) {
        var _urlString = String(urlString);
        var isFirstParam = true;
        
        // Append parameters
        if let _param_keys = param_keys {
            if let _param_values = param_values {
                // Perform check
                assert(_param_keys.count == _param_values.count, "The number of keys and values must be equal.");
                for (var i = 0; i < _param_keys.count; i++) {
                    // New field
                    if (isFirstParam) {
                        isFirstParam = false;
                        _urlString += "?";
                    } else {
                        _urlString += "&";
                    }
                    
                    // Append value
                    _urlString += self.encodeToPercentEscapeString(_param_keys[i])! + "=" + self.encodeToPercentEscapeString(_param_values[i])!;
                }
            }
        }
        
        // Create NSURL and NSURLRequest
        var _url = NSURL(string: _urlString)!;
        var _req: NSURLRequest;
        
        // Set timeoutInterval
        if let _timeoutInterval = timeoutInterval {
            _req = NSURLRequest(URL: _url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: _timeoutInterval);
        } else {
            _req = NSURLRequest(URL: _url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: FLDefaultTimeoutInterval);
        }
        
        // Send request
        NSURLConnection.sendAsynchronousRequest(_req, queue: NSOperationQueue.mainQueue(), completionHandler: completionHandler)
    }
}
