//
//  This file is part of Nextbus Tracker.
//
//  Created by Yunzhu Li on 05/09/15.
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
import MapKit

class NTMAStops: NSObject, MKAnnotation {
    var title: String
    var coordinate: CLLocationCoordinate2D
    var info: String
    var stopIndex: Int
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, stopIndex: Int) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.stopIndex = stopIndex;
    }
}
