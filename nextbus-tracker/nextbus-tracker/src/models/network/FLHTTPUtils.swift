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
    static let FLDefaultTimeoutInterval: TimeInterval = 5
    
    /* PercentEscape Encoder */
    static func encodeToPercentEscapeString(input: String) -> String? {
        return input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    /* Send asynchronous request */
    static func sendAsynchronousRequest(urlString: String, param_keys: [String]?, param_values: [String]?, timeoutInterval: TimeInterval?, completionHandler: @escaping (URLResponse?, Data?, Error?) -> Void) {
        var _urlString = String(urlString)
        var isFirstParam = true
        
        // Append parameters
        if let _param_keys = param_keys {
            if let _param_values = param_values {
                // Perform check
                assert(_param_keys.count == _param_values.count, "The number of keys and values must be equal.")
                for i in 0..<_param_keys.count {
                    // New field
                    if (isFirstParam) {
                        isFirstParam = false
                        _urlString += "?"
                    } else {
                        _urlString += "&"
                    }
                    
                    // Append value
                    _urlString += self.encodeToPercentEscapeString(input: _param_keys[i])! + "=" + self.encodeToPercentEscapeString(input: _param_values[i])!
                }
            }
        }
        
        // Log URL while debugging
        #if arch(i386) || arch(x86_64)
            NSLog("%@", _urlString)
        #endif
        
        // Create NSURL and NSURLRequest
        let _url = NSURL(string: _urlString)!
        var _req: URLRequest
        
        // Set timeoutInterval
        if let _timeoutInterval = timeoutInterval {
            _req = URLRequest(url: _url as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: _timeoutInterval)
        } else {
            _req = URLRequest(url: _url as URL, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: FLDefaultTimeoutInterval)
        }
        
        // Send request
        NSURLConnection.sendAsynchronousRequest(_req as URLRequest, queue: OperationQueue.main, completionHandler: completionHandler)
    }
}
