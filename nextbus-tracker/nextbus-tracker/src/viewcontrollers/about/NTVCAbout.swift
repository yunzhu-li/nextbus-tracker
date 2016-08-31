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

class NTVCAbout: UIViewController {
    
    @IBOutlet weak var lblVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();

        // Version
        if let ver = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            lblVersion.text = ver;
        }
    }
    
    @IBAction func btnLinkAct(sender: UIButton) {
        var url: String = "";
        switch sender.tag {
        case 1:
            url = "https://github.com/yunzhu-li/nextbus-tracker";
        case 2:
            url = "https://yunzhu.li";
        default:
            url = "https://yunzhu.li";
        }
        UIApplication.sharedApplication().openURL(NSURL(string: url)!);
    }
}
