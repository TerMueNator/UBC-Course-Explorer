//
//  CourseManager.swift
//  UBCExplorerIO
//
//  Created by Nucha Powanusorn on 20/7/20.
//  Copyright © 2020 Nucha Powanusorn. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol CourseManagerDelegate {
    func didUpdateSuccessfully(_ result: Any, _ dictResult: [String : String]?)
    func didFailWithError(error: Error)
}

struct CourseManager {
    let baseURL = "https://ubcexplorer.io/"
    var delegate: CourseManagerDelegate?
    
    func fetchAllCourse() {
        let urlString = "\(baseURL)getAllCourses"
        performTask(with: urlString, fetchAllCourse: true)
    }
    
    func fetchCourseData(name courseName: String) {
        let separatedCourseNameArray = courseName.components(separatedBy: " ")
        let deptName: String = separatedCourseNameArray[0].uppercased()
        let courseNumber: String = separatedCourseNameArray[1]
        let urlString = "\(baseURL)getCourseInfo/\(deptName)%20\(courseNumber)"
        performTask(with: urlString, fetchAllCourse: false)
    }
    
    func performTask(with urlString: String, fetchAllCourse: Bool) {
        //1. create url
        if let url = URL(string: urlString) {
            //2. create session
            let session = URLSession(configuration: .default)
            //3. add task to session
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("PERFORMTASKERROR")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if fetchAllCourse {
                        self.processCourseList(with: safeData)
                    } else {
                        self.processCourseInfo(with: safeData)
                    }
                }
            }
            //4. start task
            task.resume()
        }
    }
    
    func processCourseList(with data: Data) {
        do {
            var coursesArray: [String] = []
            var coursesDict: [String : String] = [:]
            if let safeArray = try JSON(data: data).array {
                for course in safeArray {
                    let courseCode = course["code"].string!
                    let courseName = course["name"].string!
                    coursesArray.append(courseCode)
                    coursesDict[courseCode] = courseName
                }
                self.delegate?.didUpdateSuccessfully(coursesArray.sorted(), coursesDict)
            }
        } catch {
            print("PROCESSCOURSELISTERROR")
            delegate?.didFailWithError(error: error)
        }
    }
    
    func processCourseInfo(with data: Data) {
        do {
            var courseDetail: [[String]] = []
            let jsonData = try JSON(data: data)
            let courseName = [jsonData["name"].string!]
            let courseDesc = [jsonData["desc"].string!]
            let coursePrer = [jsonData["prer"].string ?? "N/A"]
            let courseCrer = [jsonData["crer"].string ?? "N/A"]
            let courseLink = [jsonData["link"].string ?? "N/A"]
            var courseReq: [String] {
                var array: [String] = []
                if let reqs = jsonData["depn"].array {
                    for item in reqs {
                        if let safeItemStr = item.string {
                            array.append(safeItemStr)
                        }
                    }
                }
                if array == [] {
                    array = ["N/A"]
                }
                
                return array.sorted()
            }
            courseDetail.append(courseName)
            courseDetail.append(courseDesc)
            courseDetail.append(coursePrer)
            courseDetail.append(courseCrer)
            courseDetail.append(courseReq)
            courseDetail.append(courseLink)
                        
            delegate?.didUpdateSuccessfully(courseDetail, nil)
            
        } catch {
            print("PROCESSCOURSEINFOERROR")
            delegate?.didFailWithError(error: error)
        }
    }
}
