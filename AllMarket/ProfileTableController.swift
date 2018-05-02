//
//  ProfileTableController.swift
//  AllMarket
//
//  Created by MAC on 2017. 9. 4..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import UIKit
import Alamofire
import DKImagePickerController

class ProfileTableController: UITableViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileBtn: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var itemFixed: UILabel!
    @IBOutlet weak var followerFixed: UILabel!
    @IBOutlet weak var followingFixed: UILabel!
    
    @IBOutlet weak var itemBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var telSwitch: UISwitch!
    @IBOutlet weak var guideView: UIView!
    
    @IBOutlet weak var firstLine: UIView!
    @IBOutlet weak var secondLine: UIView!
    
    @IBOutlet weak var nickNameInterval: NSLayoutConstraint!
    
    let myData = UserDefaults.standard
    
    var telSetting = ""
    var tel = ""
    var finalDate = ""
    
    let user_idx = UserDefaults.standard.object(forKey: "user_idx") as! String
    
    var picker: UIImagePickerController = UIImagePickerController()
    let pickerController = DKImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            if UIScreen.main.nativeBounds.height != 2436 {
                tableView.contentInsetAdjustmentBehavior = .never
            } else {
                tableView.contentInsetAdjustmentBehavior = .always
            }
            
        } else if #available(iOS 10.0, *) {
            
            backBtn.frame.origin.y = 14
            nickNameInterval.constant = 20
        }
        
        let width = self.view.frame.width / 3
        let labelY = self.guideView.frame.height - 72.0
        let fixedLabelY = self.guideView.frame.height - 52.0
        let btnY = self.guideView.frame.height - 84
        let lineY = self.guideView.frame.height - 64.0
        
        print("profile labelY: \(self.guideView.frame.height)")
        print("profile labelY: \(labelY)")
        
        productLabel.frame = CGRect(x: 0, y: labelY, width: width, height: 16)
        followerLabel.frame = CGRect(x: width, y: labelY, width: width, height: 16)
        followingLabel.frame = CGRect(x: width * 2, y: labelY, width: width, height: 16)

        itemFixed.frame = CGRect(x: 0, y: fixedLabelY, width: width, height: 16)
        followerFixed.frame = CGRect(x: width, y: fixedLabelY, width: width, height: 16)
        followingFixed.frame = CGRect(x: width * 2, y: fixedLabelY, width: width, height: 16)
        
        itemBtn.frame = CGRect(x: 0, y: btnY, width: width, height: 84)
        followerBtn.frame = CGRect(x: width, y: btnY, width: width, height: 84)
        followingBtn.frame = CGRect(x: width * 2, y: btnY, width: width, height: 84)

        firstLine.frame = CGRect(x: width, y: lineY, width: 1, height: 18)
        secondLine.frame = CGRect(x: width * 2, y: lineY, width: 1, height: 18)
        
        self.tabBarController?.tabBar.isHidden = false
        
        guideView.backgroundColor = UIColor.init(hex: "051c30")
        
        self.addRefreshControl()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.backgroundColor = UIColor.init(hex: "ffffff")
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
        
        requestUserInfo()

        // LoginViewController에서만 네비게이션바 안 보이게
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        // 다른 뷰에선 네비게이션바 보이게
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print("계정 아이디")
            break
        case 1:
            print("전화번호")
            
            let ChangePhoneNum = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePhoneNum") as! ChangePhoneNumController
            self.navigationController?.pushViewController(ChangePhoneNum, animated: true)
            
            break
        case 2:
            print("연락처 비공개 설정")
            
            break
        case 3:
            print("새 비밀번호 설정")
            
            if myData.object(forKey: "joinpath") as! String == "FACEBOOK" {
                basicAlert(target: self, title: nil, message: "notchangefb".localized)
            } else {
                let NewPassword = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewPassword") as! NewPasswordController
                self.navigationController?.pushViewController(NewPassword, animated: true)
            }
            break
        default:
            return
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func requestUserInfo(){
        if (UserDefaults.standard.string(forKey: "token") != nil) {
            
            let parameter = ["user_idx":user_idx]
            
            Alamofire.request(domain + profileMainURL, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response(completionHandler: { (response) in
                self.parseUserInfo(JSONData: response.data!)
            })
        }
    }
    
    func parseUserInfo(JSONData: Data){
        do{
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! [String:AnyObject]
            print("JSON : \(readableJSON)")
            
            //{"profile_image":null,"nickname":null,"myItem":"0","date":null,"email":null,"tel":null,"follower":"0","following":"0","tel_view":null}
            
            if let subPath = readableJSON["profile_image"] as? String {
                let imagePath = domain + subPath
                print(imagePath)
                
                let imageData = try? Data(contentsOf : URL(string: imagePath)!)
                
                self.profileImg.image  = UIImage(data: imageData!)
                self.profileImg.layer.cornerRadius = self.profileImg.bounds.width / 2.0
                self.profileImg.clipsToBounds = true
            }
        
            if let nickName = readableJSON["nickname"] as? String {
                nicknameLabel.text = nickName
            }
            if let myItem = readableJSON["myItem"] as? String {
                productLabel.text = myItem
            }
            if let date = readableJSON["date"] as? String {
                self.subStringDate(date: date)
                
                dateLabel.text = finalDate
            }
            if let email = readableJSON["email"] as? String {
                emailLabel.text = email
            }
            if let tel = readableJSON["tel"] as? String {
                telLabel.text = tel
            }
            if let follower = readableJSON["follower"] as? String {
                followerLabel.text = follower
            }
            if let following = readableJSON["following"] as? String {
                followingLabel.text = following
            }
            if let tel_view = readableJSON["tel_view"] as? String {
                telSetting = tel_view
                if tel_view == "1" {
                    telSwitch.setOn(true, animated: true)
                } else if tel_view == "0" {
                    telSwitch.setOn(false, animated: true)
                }
            }
            
        }catch{
            print(" #### [ MyProfile error ] : \(error) #### ")
        }
        
    }
    
    @IBAction func telSettingAction(_ sender: UISwitch) {
        
        myData.set(sender.isOn, forKey: "telSetting")
        tel = String(myData.bool(forKey: "telSetting"))

        if tel == "true"{
            telSetting = "1"
        } else {
            telSetting = "0"
        }
        
        let parameter = ["tel_view":telSetting,
                         "user_idx":user_idx]
        print("[ parameter ] : \(parameter)")
        
        Alamofire.request(domain + telViewURL,
                          method: .post,
                          parameters: parameter,
                          encoding: URLEncoding.default,
                          headers: nil).response(completionHandler: {
                            (response) in
                            do {
                                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String : AnyObject]
                                print("[ JSON ] : \(readableJSON)")
                                
                            } catch {
                                print("[ tel_view error ] : \(error)")
                            }
        })
        
    }
    
    @IBAction func producAction(_ sender: UIButton) {
        
        changeView(target: self, identifier: "MyItem")
        
    }
    
    @IBAction func followerAction(_ sender: UIButton) {
        
//        changeView(target: self, identifier: "Follower")
        
        let Follower = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Follower") as! FollowerTableController
        self.navigationController?.pushViewController(Follower, animated: true)
        
    }
    
    @IBAction func followingAction(_ sender: UIButton) {
        
//        changeView(target: self, identifier: "Following")
        
        let Following = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Following") as! FollowingTableController
        self.navigationController?.pushViewController(Following, animated: true)
    }
    
    @IBAction func profileEditAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "changeProfilImg".localized, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "openCamera".localized, style: .default) { (action) in
            self.openCamera()
            
        }
        
        let galleryAction = UIAlertAction(title: "openAlbum".localized, style: .default) { (action) in
            self.openPhotoLibrary()
            
        }
        
        let cancelAction = UIAlertAction(title: "cancelTitle".localized, style: .cancel, handler: nil)
        
        picker.delegate = self
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.picker = UIImagePickerController()
            self.picker.sourceType = .camera
            self.picker.delegate = self
            self.picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
        }else{
            self.openPhotoLibrary()
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.picker = UIImagePickerController()
            self.picker.sourceType = .photoLibrary
            self.picker.delegate = self
            self.picker.allowsEditing = true

            self.present(picker, animated: true, completion: nil)
        }
    }
    
    var pickImage: UIImage?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var imageData = UIImagePNGRepresentation(image)!
        
        while imageData.count > Int(300*1024) {
            imageData = ResizeImage(imageData: imageData, reduceRatio: 0.5)
            
        }
        
        self.uploadProfileImg(imageData)
        
        pickImage = UIImage(data: imageData)!
        
        profileImg.layer.masksToBounds = false
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.clipsToBounds = true
        
        self.profileImg.image = pickImage
        
    }
    
    func ResizeImage(imageData: Data, reduceRatio: CGFloat) -> Data {
        let image = UIImage(data: imageData)!
        let size = image.size
        var newSize: CGSize
        newSize = CGSize(width: size.width * reduceRatio, height: size.height * reduceRatio)
        
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let newImageData = UIImagePNGRepresentation(newImage!)
        
        self.uploadProfileImg(newImageData!)
        
        return newImageData!
    }
    
    @IBAction func DoneBtn(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }
    
    func subStringDate(date: String) {
        
        if L102Language.currentAppleLanguage() == "ko" {
            
            let index = date.index(date.startIndex, offsetBy: 4)
            var year = date.substring(to: index)
            year += "년 "
            
            var start = date.index(date.startIndex, offsetBy: 5)
            var end = date.index(date.endIndex, offsetBy: -12)
            var range = start..<end
            
            var month = date.substring(with: range)
            month += "월 "
            
            start = date.index(date.startIndex, offsetBy: 8)
            end = date.index(date.endIndex, offsetBy: -9)
            range = start..<end
            
            var day = date.substring(with: range)
            day += "일"
            
            finalDate = "가입일 " + year + month + day
            
        } else {
            
            let index = date.index(date.startIndex, offsetBy: 4)
            var year = date.substring(to: index)
            
            var start = date.index(date.startIndex, offsetBy: 5)
            var end = date.index(date.endIndex, offsetBy: -12)
            var range = start..<end
            
            var month = date.substring(with: range)
            month += "/"
            
            start = date.index(date.startIndex, offsetBy: 8)
            end = date.index(date.endIndex, offsetBy: -9)
            range = start..<end
            
            var day = date.substring(with: range)
            day += "/"
            
            if L102Language.currentAppleLanguage() == "en" {
                finalDate = "Join Date " + day + month + year
            } else if L102Language.currentAppleLanguage() == "vi" {
                finalDate = "Ngày tham gia " + day + month + year
            }
            
        }
    }
    
    func uploadProfileImg(_ data: Data) {
        let parameters = ["user_idx":user_idx] as [String : Any]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
//            if let data = newImageData {
                multipartFormData.append(data, withName: "upload_file[0]", fileName: "image.png", mimeType: "image/png")
//            }
        }, usingThreshold: UInt64.init(),
           to: domain + profileImgEditURL,
           method: .post,
           headers: nil) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    print("response : \(response)")
                    
                    self.requestUserInfo()
                    
                    if let err = response.error {
                        print(err)
                        return
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func addRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refreshWebView(_ sender: UIRefreshControl) {
        requestUserInfo()
        sender.endRefreshing()
    }
    
}
