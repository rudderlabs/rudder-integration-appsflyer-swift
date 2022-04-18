//
//  RSAppsFlyerDestination.swift
//  RudderAppsFlyer
//
//  Created by Pallab Maiti on 04/03/22.
//

import Foundation
import RudderStack
import AppsFlyerLib

let AFEventRemoveFromCart = "remove_from_cart"

class RSAppsFlyerDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "AppsFlyer"
    var client: RSClient?
    var controller = RSController()
    var appsFlyerConfig: AppsFlyerConfig?
    
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        guard let appsFlyerConfig: AppsFlyerConfig = serverConfig.getConfig(forPlugin: self) else {
            return
        }
        self.appsFlyerConfig = appsFlyerConfig
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerConfig.devKey
        AppsFlyerLib.shared().appleAppID = appsFlyerConfig.appleAppId
        if client?.configuration.logLevel == .debug {
            AppsFlyerLib.shared().isDebug = true
        }
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        AppsFlyerLib.shared().customerUserID = message.userId
        if let traits = extractTraits(traits: message.traits) {
            var customData = [String: Any]()
            for (key, value) in traits {
                switch key {
                case RSKeys.Identify.userId:
                    break
                case RSKeys.Identify.currencyCode:
                    AppsFlyerLib.shared().currencyCode = "\(value)"
                default:
                    customData[key] = value
                }
            }
            AppsFlyerLib.shared().customData = customData
        }
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        if let event = getAppsFlyerEcommerceEvent(from: message.event) {
            /// AppsFlyer doc for Ecommere events.
            /// https://support.appsflyer.com/hc/en-us/articles/360019347957--Recommended-eCommerce-app-events
            var params = [String: Any]()
            switch event {
            case AFEventSearch:
                if let query = message.properties?[RSKeys.Ecommerce.query] {
                    params[AFEventParamSearchString] = query
                }
            case AFEventContentView, AFEventAddToWishlist, AFEventAddToCart:
                insertSingleProduct(params: &params, properties: message.properties)
            case AFEventListView:
                insertProductList(params: &params, properties: message.properties)
            case AFEventInitiatedCheckout, AFEventPurchase:
                insertMultipleProduct(params: &params, properties: message.properties)
            case AFEventRemoveFromCart:
                if let productId = message.properties?[RSKeys.Ecommerce.productId] {
                    params[AFEventParamContentId] = "\(productId)"
                }
                if let category = message.properties?[RSKeys.Ecommerce.category] {
                    params[AFEventParamContentType] = "\(category)"
                }
            default:
                if let properties = message.properties {
                    params = properties
                }
            }
            AppsFlyerLib.shared().logEvent(event, withValues: params)
        } else {
            AppsFlyerLib.shared().logEvent(message.event, withValues: message.properties)
        }
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        var screenName = ""
        if appsFlyerConfig?.useRichEventName == true {
            if !message.name.isEmpty {
                screenName = "Viewed \(message.name) Screen"
            } else {
                screenName = "Viewed Screen"
            }
        } else {
            screenName = "screen"
        }
        AppsFlyerLib.shared().logEvent(screenName, withValues: message.properties)
        return message
    }
}

// MARK: - Support methods

extension String {
    var appsFlyerEvent: String {
        var string = lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.count > 100 {
            string = String(string.prefix(100))
        }
        return string
    }
}

extension RSAppsFlyerDestination {
    // swiftlint:disable cyclomatic_complexity
    func getAppsFlyerEcommerceEvent(from rudderEvent: String) -> String? {
        switch rudderEvent {
        case RSEvents.Ecommerce.productsSearched: return AFEventSearch
        case RSEvents.Ecommerce.productAdded: return AFEventAddToCart
        case RSEvents.Ecommerce.productAddedToWishList: return AFEventAddToWishlist
        case RSEvents.Ecommerce.checkoutStarted: return AFEventInitiatedCheckout
        case RSEvents.Ecommerce.orderCompleted: return AFEventPurchase
        case RSEvents.Ecommerce.cartShared: return AFEventShare
        case RSEvents.Ecommerce.productShared: return AFEventShare
        case RSEvents.Ecommerce.productViewed: return AFEventContentView
        case RSEvents.Ecommerce.productListViewed : return AFEventListView
        case RSEvents.Ecommerce.promotionViewed: return AFEventAdView
        case RSEvents.Ecommerce.promotionClicked: return AFEventAdClick
        case RSEvents.LifeCycle.unlockAchievement: return AFEventAchievementUnlocked
        case RSEvents.Ecommerce.spendCredits: return AFEventSpentCredits
        case RSEvents.Ecommerce.productRemoved: return AFEventRemoveFromCart
        default: return nil
        }
    }
    
    func getAppsFlyerEcommerceParameter(from rudderEvent: String) -> String? {
        switch rudderEvent {
        case RSKeys.Ecommerce.paymentMethod: return AFEventParamPaymentInfoAvailable
        case RSKeys.Ecommerce.coupon: return AFEventParamCouponCode
        case RSKeys.Ecommerce.query: return AFEventParamSearchString
        default: return nil
        }
    }
    
    func extractTraits(traits: [String: Any]?) -> [String: String]? {
        var params: [String: String]?
        if let traits = traits {
            params = [String: String]()
            for (key, value) in traits {
                switch value {
                case let v as String:
                    params?[key] = v
                case let v as NSNumber:
                    params?[key] = "\(v)"
                case let v as Bool:
                    params?[key] = "\(v)"
                default:
                    break
                }
            }
        }
        return params
    }
    
    func insertMultipleProduct(params: inout [String: Any], properties: [String: Any]?) {
        guard let properties = properties else {
            return
        }
        for (key, value) in properties {
            switch key {
            case RSKeys.Ecommerce.currency:
                params[AFEventParamCurrency] = "\(value)"
            case RSKeys.Ecommerce.revenue:
                params[AFEventParamRevenue] = Double("\(value)")
            case RSKeys.Ecommerce.total:
                params[AFEventParamPrice] = Int("\(value)")
            case RSKeys.Ecommerce.orderId:
                params[AFEventParamOrderId] = "\(value)"
                params[AFEventParamReceiptId] = "\(value)"
            case RSKeys.Ecommerce.products:
                if let products = value as? [[String: Any]] {
                    var ids = [String]()
                    var categories = [Any?]()
                    var quantities = [Int]()
                    for product in products {
                        if let productId = product[RSKeys.Ecommerce.productId] {
                            ids.append("\(productId)")
                        }
                        if let category = product[RSKeys.Ecommerce.category] {
                            categories.append("\(category)")
                        }
                        if let productQuantity = product[RSKeys.Ecommerce.quantity], let quantity = Int("\(productQuantity)") {
                            quantities.append(quantity)
                        }
                    }
                    params[AFEventParamContentId] = ids
                    params[AFEventParamContentType] = categories
                    params[AFEventParamQuantity] = quantities
                }
            default: break
            }
        }
    }
    
    func insertSingleProduct(params: inout [String: Any], properties: [String: Any]?) {
        guard let properties = properties else {
            return
        }
        for (key, value) in properties {
            switch key {
            case RSKeys.Ecommerce.currency:
                params[AFEventParamCurrency] = "\(value)"
            case RSKeys.Ecommerce.price:
                params[AFEventParamPrice] = Int("\(value)")
            case RSKeys.Ecommerce.productId:
                params[AFEventParamContentId] = "\(value)"
            case RSKeys.Ecommerce.category:
                params[AFEventParamContentType] = "\(value)"
            case RSKeys.Ecommerce.quantity:
                params[AFEventParamQuantity] = Int("\(value)")
            default: break
            }
        }
    }
    
    func insertProductList(params: inout [String: Any], properties: [String: Any]?) {
        guard let properties = properties else {
            return
        }
        if let products = properties[RSKeys.Ecommerce.products] as? [[String: Any]] {
            var ids = [String]()
            var categories = [Any?]()
            for product in products {
                if let productId = product[RSKeys.Ecommerce.productId] {
                    ids.append("\(productId)")
                }
                if let category = product[RSKeys.Ecommerce.category] {
                    categories.append("\(category)")
                }
            }
            params[AFEventParamContentList] = ids
            params[AFEventParamContentType] = categories
        }
        
    }
}

struct AppsFlyerConfig: Codable {
    private let _devKey: String?
    var devKey: String {
        return _devKey ?? ""
    }
    
    private let _appleAppId: String?
    var appleAppId: String {
        return _appleAppId ?? ""
    }
    
    private let _useRichEventName: Bool?
    var useRichEventName: Bool {
        return _useRichEventName ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case _devKey = "devKey"
        case _appleAppId = "appleAppId"
        case _useRichEventName = "useRichEventName"
    }
}

@objc
public class RudderAppsFlyerDestination: RudderDestination {
    
    public override init() {
        super.init()
        plugin = RSAppsFlyerDestination()
    }
    
}
