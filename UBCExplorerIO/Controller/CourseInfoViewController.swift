//
//  CourseInfoTableViewController.swift
//  UBCExplorerIO
//
//  Created by Nucha Powanusorn on 21/7/20.
//  Copyright © 2020 Nucha Powanusorn. All rights reserved.
//

import UIKit
import WebKit

class CourseInfoViewController: UITableViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var selectedCourse: String = ""
    var courseManager = CourseManager()
    var courseInfo: [[String]] = [[]]
    let headerTitle: [String] = ["Course Name", "Description", "Pre-requisites", "Co-requisites", "Course required for", "Link"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        courseManager.delegate = self
        courseManager.fetchCourseData(name: selectedCourse)        
    }
    
    @IBAction func websiteButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let safariAction = UIAlertAction(title: "Open in Safari", style: .default) { (action) in
            guard let url = URL(string: self.courseInfo.last![0]) else { return }
            UIApplication.shared.open(url)
        }
        let inAppAction = UIAlertAction(title: "Open in app", style: .default) { (action) in
            self.performSegue(withIdentifier: "toWebView", sender: self)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alertController.addAction(safariAction)
        alertController.addAction(inAppAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebView" {
            let destinationVC = segue.destination as! WebViewController
            destinationVC.urlString = courseInfo.last![0]
            destinationVC.selectedCourse = self.selectedCourse
            let backItem = UIBarButtonItem()
            backItem.title = selectedCourse
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return courseInfo.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseInfo[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseInfoCell", for: indexPath)
        cell.textLabel?.text = courseInfo[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle[section]
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            if let courseName = cell.textLabel?.text, checkValidCourse(name: courseName) {
                courseManager.fetchCourseData(name: courseName)
                selectedCourse = courseName
            }
        }
    }
    
    func checkValidCourse(name: String) -> Bool {
        let separatedCourseNameArray = name.components(separatedBy: " ")
        if separatedCourseNameArray.count == 2, separatedCourseNameArray[0].count == 4, separatedCourseNameArray[1].count == 3 {
            return true
        }
        return false
    }
}

extension CourseInfoViewController: CourseManagerDelegate {
    func didUpdateSuccessfully(_ result: Any, _ dictResult: [String : String]?) {
        DispatchQueue.main.async {
            if let resultArrArr = result as? [[String]] {
                self.courseInfo = resultArrArr
                print(resultArrArr)
                self.navigationItem.title = self.selectedCourse
                self.tableView.reloadData()
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
