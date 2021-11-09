//
//  AppDelegate.swift
//  roulette
//
//  Created by USER on 2021/06/15.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        Realm.Configuration.defaultConfiguration = Realm.Configuration(
//            schemaVersion: 1, //初期値は0
//            migrationBlock: { migration, oldSchemeVersion in
//                //現在のversionより古いversionはデータ構造の移行をしますよ〜
//                if oldSchemeVersion < 1 {
//                    //保存先の変数名が変わった例
//                    //migration.renameProperty(onType: RouletteData.className(), from: "name", to: "fullName")
//                }
//            })
        FirebaseApp.configure()
        //ステータスバーのボタンをダークモードに対応
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),.foregroundColor: UIColor.dynamicColor(light: .black, dark: .white)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),.foregroundColor: UIColor.dynamicColor(light: .black, dark: .white)], for: .highlighted)
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

