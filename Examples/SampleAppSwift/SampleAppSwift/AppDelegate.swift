//
//  AppDelegate.swift
//  ExampleSwift
//
//  Created by Arnab Pal on 09/05/20.
//  Copyright © 2020 RudderStack. All rights reserved.
//

import UIKit
import Rudder
import RudderAppsFlyer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var client: RSClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config: RSConfig = RSConfig(writeKey: "1wvsoF3Kx2SczQNlx1dvcqW9ODW")
            .dataPlaneURL("https://rudderstacz.dataplane.rudderstack.com")
            .loglevel(.debug)
            .trackLifecycleEvents(true)
            .recordScreenViews(true)
        
        client = RSClient.sharedInstance()
        client?.configure(with: config)

        client?.addDestination(RudderAppsFlyerDestination())
        sendEvents()
        return true
    }
    
    func sendEvents() {
        identifyEvents()
        screenEvents()
        trackEvents()
    }
    
    func identifyEvents() {
        RSClient.sharedInstance().identify("user-iOS-1", traits: [
            RSKeys.Identify.userId: "User-ID-1", //It should be dropped
            RSKeys.Identify.currencyCode: "USD",
            "email": "test@example.com"
        ])
    }
    
    func screenEvents() {
        RSClient.sharedInstance().screen("Screen Name")
    }
    
    func trackEvents() {
        // Custom Events
        RSClient.sharedInstance().track("Empty events")
        RSClient.sharedInstance().track("Custom events", properties: [
            "key-1": "value-1",
            "key-2": "value-2"
        ])
        
        // E-Commerce events
        func ecommerceEvents() {
            let singleProduct: [String: Any] = [
                RSKeys.Ecommerce.currency: "USD",
                RSKeys.Ecommerce.price: 1000,
                RSKeys.Ecommerce.productId: "1001",
                RSKeys.Ecommerce.category: "Gold",
                RSKeys.Ecommerce.quantity: 1
            ]
            let singleProduct2: [String: Any] = [
                RSKeys.Ecommerce.currency: "USD",
                RSKeys.Ecommerce.price: 2000,
                RSKeys.Ecommerce.productId: "2001",
                RSKeys.Ecommerce.category: "Silver",
                RSKeys.Ecommerce.quantity: 2
            ]
            let multipleProducts: [[String: Any]] = [singleProduct, singleProduct2]
            let properties: [String: Any] = [
                RSKeys.Ecommerce.currency: "USD",
                RSKeys.Ecommerce.revenue: "500",
                RSKeys.Ecommerce.total: 600,
                RSKeys.Ecommerce.orderId: 3001,
                RSKeys.Ecommerce.category: "Fruits",
                RSKeys.Ecommerce.products: multipleProducts
            ]
            // AFEventSearch
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productsSearched, properties: [
                RSKeys.Ecommerce.query: "query"
            ])
            
            // AFEventContentView
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productViewed, properties: singleProduct)
            // AFEventAddToWishlist
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productAddedToWishList, properties: singleProduct)
            // AFEventAddToCart
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productAdded, properties: singleProduct)

            // AFEventListView
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productListViewed, properties: properties)
            
            // AFEventInitiatedCheckout
            RSClient.sharedInstance().track(RSEvents.Ecommerce.checkoutStarted, properties: properties)
            // AFEventPurchase
            RSClient.sharedInstance().track(RSEvents.Ecommerce.orderCompleted, properties: properties)
            
            // AFEventRemoveFromCart
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productRemoved, properties: [
                RSKeys.Ecommerce.productId: 8001,
                RSKeys.Ecommerce.category: "Shoe"
            ])
        }
        ecommerceEvents()
        
        // Newly added events
        func newMappedEvents() {
            // AFEventShare
            RSClient.sharedInstance().track(RSEvents.Ecommerce.cartShared)
            // AFEventShare
            RSClient.sharedInstance().track(RSEvents.Ecommerce.productShared)
            // AFEventAdView
            RSClient.sharedInstance().track(RSEvents.Ecommerce.promotionViewed)
            // AFEventAdClick
            RSClient.sharedInstance().track(RSEvents.Ecommerce.promotionClicked)
            // AFEventAchievementUnlocked
            RSClient.sharedInstance().track(RSEvents.LifeCycle.unlockAchievement)
            // AFEventSpentCredits
            RSClient.sharedInstance().track(RSEvents.Ecommerce.spendCredits)
        }
        newMappedEvents()
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

extension UIApplicationDelegate {
    var client: RSClient? {
        if let appDelegate = self as? AppDelegate {
            return appDelegate.client
        }
        return nil
    }
}
