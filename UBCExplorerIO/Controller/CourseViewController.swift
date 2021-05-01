//
//  ViewController.swift
//  UBCExplorerIO
//
//  Created by Nucha Powanusorn on 20/7/20.
//  Copyright © 2020 Nucha Powanusorn. All rights reserved.
//

import UIKit
import ProgressHUD
import BiometricAuthentication

class CourseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var courseManager = CourseManager()
    var coursesArray: [String] = []
    var selectedCourse: String = ""
    var filteredData: [String] = []
    var coursesDict: [String: String] = [:]
    var userDefaults = UserDefaults.standard
    var isBackground: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredData = coursesArray
        
//        addBlurView()
        
        setupTableView()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
        
        courseManager.delegate = self
        
        if let savedCourseList = userDefaults.dictionary(forKey: "coursesDict"), let savedCourseArray = userDefaults.array(forKey: "coursesArray") {
            coursesDict = savedCourseList as! [String: String]
            coursesArray = savedCourseArray as! [String]
            filteredData = savedCourseArray as! [String]
        } else {
            refreshCourseList()
        }
        
        searchBar.delegate = self
        
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCourseInfo" {
            let destinationVC = segue.destination as! CourseInfoViewController
            destinationVC.selectedCourse = self.selectedCourse
            destinationVC.navigationItem.title = selectedCourse
        }
    }
    
    @IBAction func refreshCourseButton(_ sender: UIBarButtonItem) {
        refreshCourseList()
    }
    
    func refreshCourseList() {
        courseManager.fetchAllCourse()
        ProgressHUD.animationType = .circleSpinFade
        ProgressHUD.fontStatus = UIFont(name: "Avenir", size: 24)!
        ProgressHUD.show("Loading courses", interaction: false)
    }
    
//    func addBlurView() {
//        let blurEffect = UIBlurEffect(style: .dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurEffectView.tag = 999
//
//        let authButton = UIButton(frame: CGRect(x: self.view.frame.size.width / 2 - 80, y: self.view.frame.size.height / 2 - 20, width: 160, height: 40))
//        authButton.setTitle("Unlock", for: .normal)
//        authButton.layer.cornerRadius = 10
//        authButton.backgroundColor = .systemGray
//        authButton.addTarget(self, action: #selector(authButtonPressed), for: .touchUpInside)
//        authButton.tag = 998
//
//        UIApplication.shared.keyWindow?.addSubview(blurEffectView)
//        UIApplication.shared.keyWindow?.addSubview(authButton)
//
//    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CourseListCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.keyboardDismissMode = .onDrag
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath.row)
            }
        }
    }
    
//    @objc func authButtonPressed() {
//        if let authButton = UIApplication.shared.keyWindow?.viewWithTag(998), let blurView = UIApplication.shared.keyWindow?.viewWithTag(999) {
//            if BioMetricAuthenticator.canAuthenticate() {
//                BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
//                    switch result {
//                    case .success(_):
//                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
//                            authButton.alpha = 0
//                            blurView.alpha = 0
//                        }) { (_) in
//                            authButton.isHidden = true
//                            blurView.isHidden = true
//                        }
//
//                        print("auth success")
//                        self.isBackground = false
//                    case .failure(let error):
//                        print("auth error, \(error)")
//                    }
//                }
//            } else {
//                BioMetricAuthenticator.authenticateWithPasscode(reason: "") { (result) in
//                    switch result {
//                    case .success(_):
//                        authButton.isHidden = true
//                        blurView.isHidden = true
//                        print("auth success")
//                    case .failure(let error):
//                        print("auth error, \(error)")
//                    }
//                }
//            }
//        }
//    }
    
//    @objc func appDidEnterBackground() {
//        print("app entered background")
//        if let authButton = UIApplication.shared.keyWindow?.viewWithTag(998), let blurView = UIApplication.shared.keyWindow?.viewWithTag(999) {
//            authButton.alpha = 1
//            blurView.alpha = 1
//            authButton.isHidden = false
//            blurView.isHidden = false
//            isBackground = true
//        }
//    }
    
//    @objc func appDidBecomeActive() {
//        if isBackground {
//            authButtonPressed()
//        }
//    }
    
}

//MARK: - UITableViewDelegate
extension CourseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = filteredData[indexPath.row]
        performSegue(withIdentifier: "toCourseInfo", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension CourseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CourseListCell
        cell.courseNameLabel.text = filteredData[indexPath.row]
        cell.courseDescriptionLabel.text = coursesDict[filteredData[indexPath.row]]
        return cell
    }
}

extension CourseViewController: CourseManagerDelegate {
    func didUpdateSuccessfully(_ result: Any, _ dictResult: [String : String]?) {
        DispatchQueue.main.async {
            if let resultArray = result as? [String], let resultDict = dictResult {
                self.coursesArray = resultArray
                self.coursesDict = resultDict
                self.filteredData = resultArray
                self.tableView.reloadData()
                ProgressHUD.showSucceed("Loaded", interaction: false)
                
                self.userDefaults.set(resultArray, forKey: "coursesArray")
                self.userDefaults.set(resultDict, forKey: "coursesDict")
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - UISearchBarDelegate
extension CourseViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? coursesArray : coursesArray.filter({ (dataString) -> Bool in
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredData = coursesArray
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
