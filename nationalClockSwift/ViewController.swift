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
    
    static let currentNation = "Asia/Seoul"
    
    var savedNation = [[String : String]]()
    var shownNation = [[String : String]]()
    var timeZoneArray = [[String : String]]()
    var national = ["Asia/Seoul","America/Chicago", "Asia/Bangkok", "Europe/Amsterdam"] //Added Nation by customer
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action:#selector(showEditing(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        for tz in TimeZone.knownTimeZoneIdentifiers {
            let timeZone = TimeZone(identifier: tz)
            var translatedName : String = timeZone?.localizedName(for: .shortGeneric, locale: Locale(identifier: "ko_KR")) ?? ""

            if translatedName.hasSuffix(" 시간"){
                translatedName = String(translatedName.prefix(translatedName.count - 3))
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            
            //distance of Hour
             dateFormatter.dateFormat = "MM/dd HH:mm" //immidiatly setting for calculate
            let fromDate = dateFormatter.string(from: Date())
            dateFormatter.timeZone = timeZone
            let toDate = dateFormatter.string(from: Date())
            
            let components = Calendar.current.dateComponents([.hour], from: dateFormatter.date(from: fromDate) ?? Date(), to: dateFormatter.date(from: toDate) ?? Date())
            
             dateFormatter.dateFormat = "HH:mm"
            //Saved Date
            if national.contains(tz) {
                savedNation.append(["nation" : translatedName , "time": dateFormatter.string(from: Date()), "distance": String(components.hour ?? 0)])
            }
            //All of Date
            timeZoneArray.append(["nation" : translatedName , "time": dateFormatter.string(from: Date()), "distance": String(components.hour ?? 0)])


            
            print(components)
        }

        
        searchDimView.isHidden = true
        searchTableView.isHidden = true
        tableViewHeightConstraint.constant = 0
        
        searchTableView.rx.contentOffset.subscribe(onNext: { point in
            print(point)
        }).disposed(by: disposeBag)
        
        searchBar
            .rx.text
            .orEmpty
            .subscribe(onNext: { [unowned self] query in
                self.shownNation = self.timeZoneArray.filter{ $0["nation"]?.hasPrefix(query) ?? false}
                self.tableViewHeightConstraint.constant = CGFloat(60 * self.shownNation.count)
                self.searchTableView.reloadData() // 테이블 뷰를 다시 불러옵니다.
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func dimViewTouched(_ sender: Any) {
        searchBar.resignFirstResponder()
        searchDimView.isHidden = true
        searchTableView.isHidden = true
        searchBar.text = ""
    }
    
    @objc func showEditing(sender: UIBarButtonItem)
    {
        if(tableView_.isEditing == true)
        {
            tableView_.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "편집"
        }
        else
        {
            tableView_.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "완료"
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath as IndexPath) as! TableViewCell
            
            let dict = savedNation[indexPath.row]
            
            cell.cellNation.text = dict["nation"]
            cell.cellTitle.text = dict["time"]
            cell.cellDistance.text = dict["distance"]
            cell.cellNation.textColor = .gray
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell", for: indexPath as IndexPath) as! SearchTableViewCell
            
            let dict = shownNation[indexPath.row]
            
            cell.searchTitle?.text = dict["nation"]
            cell.textLabel?.textColor = .blue
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
        if tableView.tag == 1 {
            let dict = shownNation[indexPath.row]
            savedNation.append(dict)
            tableView_.reloadData()
            
            searchBar.resignFirstResponder()
            searchDimView.isHidden = true
            searchTableView.isHidden = true
        }
    }
}

extension ViewController: UITableViewDelegate{

    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if tableView.tag == 0 {
            let dict = savedNation[sourceIndexPath.row]
            savedNation.remove(at: sourceIndexPath.row)
            savedNation.insert(dict, at: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tableView.tag == 0 {
                savedNation.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchDimView.isHidden = false
        searchTableView.isHidden = false
        return true
    }
}
