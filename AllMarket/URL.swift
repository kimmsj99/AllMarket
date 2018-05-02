//
//  URL.swift
//  AllMarket
//
//  Created by 김민주 on 2017. 8. 29..
//  Copyright © 2017년 MinJu. All rights reserved.
//

import Foundation

// MARK: - Domain
public let domain        = "http://allmarket-app.com"

// MARK: - Find
public let tmepPassURL      = "/index/profile/temporaryPassword"    //임시 비밀번호
public let findPassURL      = "/index/profile/findPassword"         //비번 찾기

// MARK: - Language
public let languageURL      = "/index/register/index"               //언어선택

// MARK: - Login
public let loginURL         = "/index/register/login"               //로그인

// MARK: - Join
public let certifiNumURL    = "/index/register/emailSend"           //인증번호 확인
public let nicknameCheckURL = "/index/register/nicknamecheck"       //닉네임 중복확인
public let telCheckURL      = "/index/register/telcheck"            //전화번호 중복확인
public let joinURL          = "/index/register/insertUser"          //회원가입
public let facebookCheckURL = "/index/register/facebookEmailCheck"  //페이스북 이메일 있는지 체크

// MARK: - Home
public let homeURL          = "/index/home"    //Main

// MARK: - Category
public let searchURL        = "/index/item/itemWordSearch"      //검색
public let getBCategoryURL  = "/index/category/getBCategory"    //대분류
public let getMCategoryURL  = "/index/category/getMCategory"    //중분류
public let getSCategoryURL  = "/index/category/getSCategory"    //소분류
public let selectURL        = "/index/category/categoryAccess"  //카테고리 선택
public let itemResultURL    = "/index/item/item"                //검색결과
public let filteringURL     = "/index/item/filter"              //필터링 옵션

//MARK: - Event
public let suggestEventURL      = "/index/event/suggestedEvent"     //추천 이벤트
public let affiliateEventURL    = "/index/event/affiliateEvent"     //제휴 이벤트
public let exhibitionURL        = "/index/event/exhibition"         //기획전

// MARK: - Push
public let myPushURL        = "/index/push/push_my"     //내 소식
public let noticeURL        = "/index/push/noticeList"  //공지사항

// MARK: - Profile
public let profileMainURL   = "/index/profile/profileMain"      //프로필홈
public let myProductViewURL = "/index/profile/myProduct"        //나의 상품
public let myProductCntURL  = "/index/profile/myProductCnt"     //나의 상품 개수
public let itemUpdateURL    = "/index/item/itemUpdate"          //나의 상품 업데이트
public let steamItemViewURL = "/index/profile/steamItemView"    //찜한 상품
public let steamItemCntURL  = "/index/profile/steamItem"        //찜한 상품 개수
public let commentURL       = "/index/profile/myComment"        //댓글관리
public let pushNoticeURL    = "/index/push/pushUpdate"          //푸시 알림
public let pushCheckURL     = "/index/push/pushcheck"           //푸시 체크
public let logoutURL        = "/index/profile/logoutToken"      //로그아웃
public let secessionURL     = "/index/profile/secession"        //회원탈퇴

// MARK - MyProfile
public let profileImgEditURL    = "/index/profile/uploadImage"      //프로필 이미지 편집
public let telViewURL           = "/index/profile/tel_view"         //연락처 비공개 설정
public let followerURL          = "/index/profile/follower"         //팔로워
public let addFollowerURL       = "/index/profile/addFollowing"     //팔로워 추가
public let delFollowerURL       = "/index/profile/delFollowing"     //팔로워 삭제
public let followingURL         = "/index/profile/following"        //팔로잉
public let newPhoneURL          = "/index/item/newPhone"            //새 전화번호
public let newPassWordURL       = "/index/profile/newPassword"      //새 비밀번호
//질문하기
public let QandAURL         = "/index/profile/qna"          //Q&A
public let contactURL       = "/index/profile/contact"      //1:1 문의
public let answerURL        = "/index/profile/answer"       //1:1 답변
//프로그램 정보
public let amTosURL         = "/index/profile/amTos"        //이용약관
public let amPinfoURL       = "/index/profile/amPinfo"      //개인정보취급방침

// MARK: - Floating
public let itemRegistURL    = "/index/item/itemRegister"    //상품 등록
public let imgRegistURL     = "/index/item/iosFileUpload"   //이미지 등록
//히스토리
public let saleHistoryURL   = "/index/item/saleHistory"     //판매상품 히스토리
public let eventHistoryURL  = "/index/event/eventHistory"   //이벤트 히스토리
