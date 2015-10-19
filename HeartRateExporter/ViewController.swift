//  Created by Brad Larson on 5/6/2015.
//  Sunset Lake Software LLC.

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textfieldLimit: UITextField!
    @IBOutlet weak var buttonSubmit: UIButton!
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func doExport(button : UIButton) {
        let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        button.enabled = false;
        if (HKHealthStore.isHealthDataAvailable()){
            var csvString = "Source,Time,Date,Heartrate(BPM)\n"
            self.healthStore.requestAuthorizationToShareTypes(nil, readTypes:[heartRateType], completion:{(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                
                var limit = Int(self.textfieldLimit.text!)
                limit = limit > 0 ? limit : Int(HKObjectQueryNoLimit)
                
                let query = HKSampleQuery(sampleType:heartRateType, predicate:nil, limit:limit!, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    guard results != nil else {
                        return;
                    }
                    for quantitySample in results! {
                        let quantity = (quantitySample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(fromString: "count/min")
                        
                        let sourceName = quantitySample.source.name.stringByReplacingOccurrencesOfString("\"", withString: "'")
                        let line = "\"\(sourceName)\",\(timeFormatter.stringFromDate(quantitySample.startDate)),\(dateFormatter.stringFromDate(quantitySample.startDate)),\(quantity.doubleValueForUnit(heartRateUnit))\n"
                        csvString.appendContentsOf(line)
                        print(line);
                    }
                    
                    var error:NSError? = nil
                    let fileName = "heartratedata_\(NSDate().timeIntervalSince1970).csv";
                    let documentsDir = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain:.UserDomainMask, appropriateForURL:nil, create:true)
                    do {
                        try csvString.writeToURL(NSURL(string: fileName, relativeToURL:documentsDir)!, atomically:true, encoding:NSUTF8StringEncoding)
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            let alert = UIAlertController(title: "Success", message: "\(results!.count) records exported to \(fileName)", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    } catch let error1 as NSError {
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            let alert = UIAlertController(title: nil, message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        error = error1
                    } catch {
                        fatalError()
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        button.enabled = true;
                    }
                })
                self.healthStore.executeQuery(query)
            })
        }
    }
}

