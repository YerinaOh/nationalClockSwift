//
//  ViewController.swift
//  nationalClockSwift
//
//  Created by OHYERINA on 23/04/2019.
//  Copyright © 2019 OHYERINA. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView_: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchDimView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var savedNation = [[String : String]]()
    var shownNation = [[String : String]]()
    var timeZoneArray = [[String : String]]()
    var national = ["Asia/Seoul","America/Chicago", "Asia/Bangkok", "Europe/Amsterdam"] //Added Nation by customer
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tz in TimeZone.knownTimeZoneIdentifiers {
            let timeZone = TimeZone(identifier: tz)
            var translatedName : String = timeZone?.localizedName(for: NSTimeZone.NameStyle.shortGeneric, locale: Locale(identifier: "ko_KR")) ?? ""
            
            if translatedName.hasSuffix(" 시간"){
                translatedName = String(translatedName.prefix(translatedName.count - 3))
            }
            
            let date = DateFormatter()
            date.locale = Locale(identifier: "ko_KR")
            date.timeZone = timeZone
//            date.timeZone = TimeZone(abbreviation: "KST")
            date.dateFormat = "HH:mm"

            if national.contains(tz) {
                savedNation.append(["nation" : translatedName , "time": date.string(from: Date())])
            }
            timeZoneArray.append(["nation" : translatedName , "time": date.string(from: Date())])
        }
        
        tableView_.delegate = self
        tableView_.dataSource = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchDimView.isHidden = true
        searchTableView.isHidden = true
        tableViewHeightConstraint.constant = 0
        
        searchBar
            .rx.text // RxCocoa의 Observable 속성
            .orEmpty // 옵셔널이 아니도록 만듭니다.
            .subscribe(onNext: { [unowned self] query in // 이 부분 덕분에 모든 새로운 값에 대한 알림을 받을 수 있습니다.
                self.shownNation = self.timeZoneArray.filter{ $0["nation"]?.hasPrefix(query) ?? false} // 도시를 찾기 위한 “API 요청” 작업을 합니다.
                self.tableViewHeightConstraint.constant = CGFloat(60 * self.shownNation.count)
                self.searchTableView.reloadData() // 테이블 뷰를 다시 불러옵니다.
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func dimViewTouched(_ sender: Any) {
        searchBar.resignFirstResponder()
        searchDimView.isHidden = true
        searchTableView.isHidden = true
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath as IndexPath) as! TableViewCell
            
            let dict = savedNation[indexPath.row]
            
            cell.cellNation.text = dict["nation"]
            cell.cellTitle.text = dict["time"]
            cell.cellNation.textColor = UIColor.gray
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell", for: indexPath as IndexPath) as! SearchTableViewCell
            
            let dict = shownNation[indexPath.row]
            
            cell.searchTitle?.text = dict["nation"]
            cell.textLabel?.textColor = UIColor.blue
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return savedNation.count
        }
        return shownNation.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let dict = shownNation[indexPath.row]
        savedNation.append(dict)
        tableView_.reloadData()
        
        searchBar.resignFirstResponder()
        searchDimView.isHidden = true
        searchTableView.isHidden = true
    }
}

extension ViewController: UITableViewDelegate{

}

extension ViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchDimView.isHidden = false
        searchTableView.isHidden = false
        return true
    }
}
