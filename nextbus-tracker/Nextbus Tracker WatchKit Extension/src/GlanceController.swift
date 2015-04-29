//
//  This file is part of Nextbus Tracker.
//
//  Created by Yunzhu Li on 04/29/15.
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

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet weak var lblStopTitle: WKInterfaceLabel!
    @IBOutlet weak var lblPredictions: WKInterfaceLabel!
    
    var tmRefresh: NSTimer = NSTimer();
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        super.willActivate()
        tmRefresh = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "refreshData", userInfo: nil, repeats: true);
        refreshData();
    }
    
    override func didDeactivate() {
        tmRefresh.invalidate();
        super.didDeactivate()
    }
    
    func refreshData() {
        let a = WKInterfaceController.openParentApplication(["command" : "predictions_one"], reply: { (dict, error) -> Void in
            if (error == nil || error.code == 0) {
                
                if let predictions = dict["predictions"] as? [Dictionary<String, String>] {
                    if (predictions.count > 0) {
                        self.lblStopTitle.setText(predictions[0]["stopTitle"]);
                        if (predictions[0].indexForKey("_minutes") != nil) {
                            let minutes: String = predictions[0]["_minutes"]!;
                            self.lblPredictions.setText(minutes);
                            if (minutes.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
                                self.lblPredictions.setText("No predictions");
                            }
                        } else {
                            self.lblPredictions.setText("No predictions");
                        }
                    } else {
                        self.lblStopTitle.setText("No stops added");
                        self.lblPredictions.setText("");
                    }
                }
            }
        });
    }
}
