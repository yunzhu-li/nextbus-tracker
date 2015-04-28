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

class FLLocalStorageUtils {
    
    /* Read an object from User Defaults */
    static func readObjectFromUserDefaults(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key);
    }

    /* Write an object to User Defaults */
    static func writeObjectToUserDefaults(key: String, object: AnyObject?){
        let ud = NSUserDefaults.standardUserDefaults();
        ud.setObject(object, forKey: key);
        ud.synchronize();
    }
}
