//
//  Ex_WKItemResultController.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 10. 23..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire

extension WKItemResultController {
    func parseMCategory(_ completionHandler : @escaping () -> ()){
        
        var Bidx = ""
        
        if myData.object(forKey: "Bidx") as! String == "0"{
            
            self.middleArr = ["팝니다", "삽니다"]
            
            DispatchQueue.main.async {
                completionHandler()
            }
            
        } else if myData.object(forKey: "Midx") as! String == "0" {
            
            Alamofire.request(domain + getBCategoryURL + "/\(self.language)").response(completionHandler: { (response) in
                do{
                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                    
                    for array in readableJSON {
                        let row = array as! NSDictionary
                        
                        let list = row[self.language] as! String
                        let idx = row["idx"] as! String
                        if idx != "0" {
                            self.middleArr.append(list)     //두번째 카테고리에서 선택 후 navigation Menu에 들어갈 리스트
                            self.middleIdxArr.append(idx)
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                    
                } catch {
                    print("Category Error : \(error)")
                    basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
                }
            })
            
        } else {
            Bidx = myData.object(forKey: "Bidx") as! String
            let parameter = ["idx":Bidx]
            
            Alamofire.request(domain + getMCategoryURL + "/\(self.language)", method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(
                queue: queue,
                responseSerializer: DataRequest.jsonResponseSerializer(),
                completionHandler: { (response) in
                    do{
                        let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                        print("JSON : \(readableJSON)")
                        
                        for array in readableJSON {
                            
                            let row = array as! NSDictionary
                            
                            let list = row[self.language] as! String
                            let idx = row["idx"] as! String
                            if idx != "0" {
                                self.middleArr.append(list)     //두번째 카테고리에서 선택 후 navigation Menu에 들어갈 리스트
                                self.middleIdxArr.append(idx)
                            }
                            
                        }
                        
                        DispatchQueue.main.async {
                            completionHandler()
                        }
                        
                    }catch{
                        print(" error \(error)")
                        basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
                    }
            })
        }
    }
}

extension WKItemResultController {
    func parseSCategory(_ completionHandler : @escaping () -> ()){
        
        self.smallArr.removeAll()
        var Bidx = ""
        var Midx = ""
        
        if myData.object(forKey: "Bidx") as! String == "0"{
            Alamofire.request(domain + getBCategoryURL + "/\(self.language)").response(completionHandler: { (response) in
                do{
                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                    
                    for array in readableJSON {
                        let row = array as! NSDictionary
                        
                        let list = row[self.language] as! String
                        self.smallArr.append(list)     //두번째 카테고리에서 선택 후 navigation Menu에 들어갈 리스트
                        let idx = row["idx"] as! String
                        self.smallIdxArr.append(idx)
                        
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                    
                } catch {
                    print("Category Error : \(error)")
                    basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
                }
            })
            
        } else if myData.object(forKey: "Midx") as! String == "0" {
            
            Bidx = myData.object(forKey: "Bidx") as! String
            let parameter = ["idx":Bidx]
            
            Alamofire.request(domain + getMCategoryURL + "/\(self.language)", method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(
                queue: queue,
                responseSerializer: DataRequest.jsonResponseSerializer(),
                completionHandler: { (response) in
                    do{
                        let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                        print("JSON : \(readableJSON)")
                        
                        for array in readableJSON {
                            
                            let row = array as! NSDictionary
                            
                            let list = row[self.language] as! String
                            self.smallArr.append(list)     //두번째 카테고리에서 선택 후 navigation Menu에 들어갈 리스트
                            let idx = row["idx"] as! String
                            self.smallIdxArr.append(idx)
                            
                        }
                        
                        DispatchQueue.main.async {
                            completionHandler()
                        }
                        
                    }catch{
                        print(" error \(error)")
                        basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
                    }
            })
            
        } else {
            Midx = myData.object(forKey: "Midx") as! String
            let parameter = ["idx":Midx]
            
            Alamofire.request(domain + getSCategoryURL + "/\(self.language)",
                              method: .post,
                              parameters: parameter,
                              encoding: URLEncoding.default,
                              headers: nil).response(
                                queue: queue,
                                responseSerializer: DataRequest.jsonResponseSerializer(),
                                completionHandler: { (response) in
                                    do{
                                        let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! NSArray
                                        print("JSON : \(readableJSON)")
                                        
                                        for array in readableJSON {
                                            
                                            let row = array as! NSDictionary
                                            
                                            let list = row[self.language] as! String
                                            self.smallArr.append(list)     //두번째 카테고리에서 선택 후 navigation Menu에 들어갈 리스트
                                            let idx = row["idx"] as! String
                                            self.smallIdxArr.append(idx)
                                            
                                        }
                                        
                                        DispatchQueue.main.async {
                                            completionHandler()
                                            
                                        }
                                        
                                    }catch{
                                        print(" error \(error)")
                                        basicAlert(target: self, title: "파싱 실패", message: "다시 시도해주세요")
                                    }
            })
        }
    }
}


