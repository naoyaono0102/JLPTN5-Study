//
//  AppDelegate.swift
//  JLPTN5 Study
//
//  Created by 尾野順哉 on 2020/09/07.
//  Copyright © 2020 NAOYA ONO. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? // 旧iOS対応（iOS11〜12）

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        // Google Admob初期化
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // アプリで使用するdefault.realmのパスを取得
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
        print(defaultRealmPath)
        
        // 初期データが入ったRealmファイルのパスを取得
        let bundleRealmPath = Bundle.main.url(forResource: "N5Seed", withExtension: "realm")

        // アプリで使用するRealmファイルが存在しない（= 初回利用）場合は、シードファイルをコピーする
        if !FileManager.default.fileExists(atPath: defaultRealmPath.path) {
            print("seedファイルをコピーします")
          do {
            try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
          } catch let error {
              print("error: \(error)")
            }
        }
        
        // マイグレーション処理
        migration()
        _ = try! Realm()

        return true
    }
    
    // Realmマイグレーション処理
    func migration() {
      // 次のバージョン（現バージョンが０なので、１をセット）
        let nextSchemaVersion:UInt64 = 4

      // マイグレーション設定
      let config = Realm.Configuration(
        schemaVersion: nextSchemaVersion,
        migrationBlock: { migration, oldSchemaVersion in
          if (oldSchemaVersion < nextSchemaVersion) {
          }
        })
        Realm.Configuration.defaultConfiguration = config
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

