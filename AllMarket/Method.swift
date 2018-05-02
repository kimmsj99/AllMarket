//
//  Method.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 29..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import SWSegmentedControl

let refreshControl: UIRefreshControl = UIRefreshControl()

//기본 Alert
public func basicAlert(target: UIViewController, title: String?, message: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "okTitle".localized, style: .default, handler: nil)
    
    alert.addAction(okAction)
    target.present(alert, animated: true, completion: nil)
}

//키보드에 닫기 버튼 추가
public func addToolBar(target: UIView, textField: UITextField) {
    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: target, action: #selector(UIView.endEditing(_:)))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    textField.inputAccessoryView = keyboardToolbar
}

//뷰 전환
public func changeView(target: UIViewController, identifier: String){
    let storyboard: UIStoryboard = target.storyboard!
    
    let story = storyboard.instantiateViewController(withIdentifier: identifier)
    target.present(story, animated: true, completion: nil)
}

//이메일 정규식
public func isValidEmail(str: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: str)
}

//패스워드 정규식
public func isValidPassword(str: String) -> Bool{
//      let passwordRegEx = "&(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6}$"
    let passwordRegEx = "^[a-zA-Z0-9]*$"
    
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: str)
}

//핸드폰 정규식
public func isValidPhoneNum(str: String) -> Bool{
    let phoneNumRegEx = "^\\d{3}\\d{4}\\d{4}$"
    
    let phoneNumTest = NSPredicate(format: "SELF MATCHES %@", phoneNumRegEx)
    return phoneNumTest.evaluate(with: str)
}

//비밀번호 확인
func comparePassword(target: UIViewController, passStr1 : String, passStr2 : String){
    
    if isValidPassword(str: passStr1) && isValidPassword(str: passStr2){
        guard passStr1 == passStr2 else {
            
            basicAlert(target: target, title: nil, message: "notmatchPW".localized)
            
            return
        }
    }
}

//segment 색깔 바꾸기
public func segmentedColor(_ sc: SWSegmentedControl){
    sc.titleColor = UIColor.init(hex: "2e2e2e")
    sc.unselectedTitleColor = UIColor.init(hex: "999999")
    sc.indicatorColor = UIColor.init(hex: "2e2e2e")
    sc.font = UIFont.systemFont(ofSize: 14)
}

//네비게이션바 타이틀
public func navigationTitle(_ target: UIViewController, _ title: String){
    let navibar = target.navigationItem
    navibar.title = title
}

//인증번호 만들기
public func random(length: Int = 6) -> String {
    let base = "0123456789"
    var randomString: String = ""
    
    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.characters.count))
        randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
    }
    return randomString
}

public func pwRandom(length: Int) -> String {
    
    var randomText = ""
    
    var intRandomString = ""
    var lawerRandomString = ""
    var upperRandomString = ""
    
    for _ in 0..<length{
        //숫자 랜덤
        let intRandomValue = Int(arc4random_uniform(10)) + 48
//        print("\(String(describing: UnicodeScalar(intRandomValue)!))")
        intRandomString += "\(Int(String(describing: UnicodeScalar(intRandomValue)!))!)"
        
        //대문자 랜덤
        let upperRandomValue = Int(arc4random_uniform(26)) + 65
//        print("\(String(describing: UnicodeScalar(upperRandomValue)!))")
        upperRandomString += "\(String(describing: UnicodeScalar(upperRandomValue)!))"
        
        //소문자 랜덤
        let lawerRandomValue = Int(arc4random_uniform(26)) + 97
//        print("\(String(describing: UnicodeScalar(lawerRandomValue)!))")
        lawerRandomString += "\(String(describing: UnicodeScalar(lawerRandomValue)!))"
        
    }
    
    let base = intRandomString + upperRandomString + lawerRandomString
    
    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.characters.count))
        randomText += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
    }
    
    return randomText
}

public func clearCache(){
    if #available(iOS 9.0, *) {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    } else {
        var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
        libraryPath += "/Cookies"
        
        do {
            try FileManager.default.removeItem(atPath: libraryPath)
        } catch {
            print("error")
        }
        URLCache.shared.removeAllCachedResponses()
    }
}

//searchBar textfield 설정
public func createSearchTF(target: UIView, search: UISearchController){
    
    guard let searchTextField = search.searchBar.subviews[0].subviews.last as? UITextField else {
        print(#function + " 함수에서 오류")
        return
    }
    
    searchTextField.frame = CGRect(x: 17, y: 32, width: target.bounds.width - 36, height: 36)
    searchTextField.center = CGPoint(x: target.frame.width / 2, y: 50)
    searchTextField.borderStyle = .none
    searchTextField.background = UIImage(named: "searchBar")
    searchTextField.placeholder = "searchPlacholder".localized
    searchTextField.font = UIFont.systemFont(ofSize: 13)
    
    let leftImage = UIView(frame: CGRect(x: 0, y: 0, width: searchTextField.frame.width - 238.5, height: searchTextField.frame.height))
    searchTextField.leftViewMode = .always
    searchTextField.leftView = leftImage
    
    let rightImage = UIImageView(image: UIImage(named: "searchIcon"))
    if let size = rightImage.image?.size {
        rightImage.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 23, height: size.height)
    }
    rightImage.contentMode = UIViewContentMode.center
    searchTextField.rightView = rightImage
    searchTextField.rightViewMode = .unlessEditing

    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: target, action: #selector(UIView.endEditing(_:)))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    searchTextField.inputAccessoryView = keyboardToolbar
}

public func calculateWidthConstant(_ target: UIViewController, _ value : CGFloat ) -> CGFloat {
    let v = target.view.frame.width
    return (value / 375) * v
}

public func calculateHeightConstant(_ target: UIViewController, _ value : CGFloat ) -> CGFloat {
    let v = target.view.frame.height
    return (value / 667) * v
}

