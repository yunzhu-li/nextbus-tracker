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


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var tblStops: WKInterfaceTable!
    
    var tmRefresh: NSTimer = NSTimer();
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()
        tmRefresh = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: "refreshData", userInfo: nil, repeats: true);
        refreshData();
    }

    override func didDeactivate() {
        tmRefresh.invalidate();
        super.didDeactivate()
    }
    
    func refreshData() {
        let a = WKInterfaceController.openParentApplication(["command" : "predictions_short"], reply: { (dict, error) -> Void in
            if (error == nil || error.code == 0) {
                
                if let predictions = dict["predictions"] as? [Dictionary<String, String>] {
                    
                    // No stops bookmarked
                    if (predictions.count == 0) {
                        self.tblStops.setNumberOfRows(1, withRowType: "tblRowStops");
                        if let row = self.tblStops.rowControllerAtIndex(0) as? NTTblRowStops {
                            row.lblStopTitle.setText("No saved stops");
                            row.lblPredictions.setText("Please add stops on iPhone App.");
                        }
                        return;
                    }
                    
                    self.tblStops.setNumberOfRows(predictions.count, withRowType: "tblRowStops");
                    for (var i = 0; i < self.tblStops.numberOfRows; i++) {
                        if let row = self.tblStops.rowControllerAtIndex(i) as? NTTblRowStops {
                            row.lblStopTitle.setText(predictions[i]["stopTitle"]);
                            
                            if (predictions[i].indexForKey("_minutes") != nil) {
                                let minutes: String = predictions[i]["_minutes"]!;
                                row.lblPredictions.setText(minutes);
                                if (minutes.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
                                    row.lblPredictions.setText("No predictions.");
                                }
                            } else {
                                row.lblPredictions.setText("No predictions.");
                            }
                        }
                    }
                }
            }
        });
    }
}
