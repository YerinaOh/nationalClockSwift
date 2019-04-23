//
//  ViewController.swift
//  nationalClockSwift
//
//  Created by OHYERINA on 23/04/2019.
//  Copyright © 2019 OHYERINA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView_: UITableView!
    
    var national = [String]()
    var timeZoneArray = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        _ = TimeZone.knownTimeZoneIdentifiers
        for tz in TimeZone.knownTimeZoneIdentifiers {
            let timeZone = TimeZone(identifier: tz)
            
            
            let date = DateFormatter()
            date.locale = Locale(identifier: "ko_KR")
            date.timeZone = timeZone // "2018-03-21 18:07:27"
//            date.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 22:06:39"
            date.dateFormat = "MM / dd HH:mm"

            timeZoneArray.append(["nation" : tz, "time": date.string(from: Date())])
        }
        
        tableView_.delegate = self
        tableView_.dataSource = self
       // tableView_.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath as IndexPath) as! TableViewCell
        
        let dict = timeZoneArray[indexPath.row]
        
        cell.cellNation.text = dict["nation"]
        cell.cellTitle.text = dict["time"]
        cell.cellTitle.textColor = UIColor.black
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeZoneArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ViewController: UITableViewDelegate{

}
