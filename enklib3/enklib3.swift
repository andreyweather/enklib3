import Foundation
import SwiftUI


private var session = ""
private var token = ""
private var account = ""


private var token_pref: String { return "TOKEN" }
private var session_pref: String { return "SESSION_ID" }
private var account_pref: String {return "ACCOUNT"}
private var email_pref: String { return "EMAIL" }
private var phone_pref: String { return "PHONE" }


private var libraryInit = false
private var addContactRequest = false
private var contactInfo: [String: Any] = ["":""]

private var userCat = "prod"

public func logOut () {
    
    UserDefaults.standard.removeObject(forKey: session_pref)
    UserDefaults.standard.removeObject(forKey: token_pref)
    UserDefaults.standard.removeObject(forKey: email_pref)
    UserDefaults.standard.removeObject(forKey: phone_pref)
    

}

func getUrl (selectUser: String, selectUrl: String) -> String {
    
    var url = ""
    
    let devUrl: [String: String] = ["createSession":"https://dev.ext.enkod.ru/sessions",
                                    "startSession":"https://dev.ext.enkod.ru/sessions/start",
                                    "subscribePush":"https://dev.ext.enkod.ru/mobile/subscribe",
                                    "unsubscribePush":"https://dev.ext.enkod.ru/mobile/unsubscribe",
                                    "clickPush":"https://dev.ext.enkod.ru/mobile/click/",
                                    "refreshToken":"https://dev.ext.enkod.ru/mobile/token",
                                    
                                    "cart":"https://dev.ext.enkod.ru/product/cart",
                                    "favourite":"https://dev.ext.enkod.ru/product/favourite",
                                    "pageOpen":"https://dev.ext.enkod.ru/page/open",
                                    "productOpen":"https://dev.ext.enkod.ru/product/open",
                                    "productBuy":"https://dev.ext.enkod.ru/product/order",
                                    "subscribe":"https://dev.ext.enkod.ru/subscribe",
                                    "addExtraFields":"https://dev.ext.enkod.ru/addExtraFields",
                                    "getPerson":"https://dev.ext.enkod.ru/getCartAndFavourite",
                                    "updateBySession":"https://dev.ext.enkod.ru/updateBySession"]
    
    
    let prodUrl: [String: String] =  ["createSession":"https://ext.enkod.ru/sessions",
                                      "startSession":"https://ext.enkod.ru/sessions/start",
                                      "subscribePush":"https://ext.enkod.ru/mobile/subscribe",
                                      "unsubscribePush":"https://ext.enkod.ru/mobile/unsubscribe",
                                      "clichPush":"https://ext.enkod.ru/mobile/click/",
                                      "refreshToken":"https://ext.enkod.ru/mobile/token",
                                      
                                      "cart":"https://ext.enkod.ru/product/cart",
                                      "favourite":"https://ext.enkod.ru/product/favourite",
                                      "pageOpen":"https://ext.enkod.ru/page/open",
                                      "productOpen":"https://ext.enkod.ru/product/open",
                                      "productBuy":"https://ext.enkod.ru/product/order",
                                      "subscribe":"https://ext.enkod.ru/subscribe",
                                      "addExtraFields":"https://ext.enkod.ru/addExtraFields",
                                      "getPerson":"https://ext.enkod.ru/getCartAndFavourite",
                                      "updateBySession":"https://ext.enkod.ru/updateBySession"]
    
    
    if selectUser == "dev" {
        url = devUrl [selectUrl] ?? ""
    }
    
    
    
    if selectUser == "prod" {
        url =  prodUrl [selectUrl] ?? ""
    }
    
    return url
    
}



public func enkodConnect (_account: String?) {
    
    if (_account != nil) {
        
        account = _account ?? "nil"
        
    }
    
    
    var getToken: String? { return UserDefaults.standard.object(forKey: token_pref) as? String }
    var getSessionID: String? { return UserDefaults.standard.object(forKey: session_pref) as? String }
    var getAccount: String? {return UserDefaults.standard.object(forKey: account_pref) as? String }
    
    
    
    if getSessionID == nil {
        
        createSession(account: account, token: getToken ?? "")
        
    }
    
    else {
        
        if getSessionID != nil {
            
            
            startSession (account: getAccount ?? "", sessionID: getSessionID ?? "", token: getToken ?? "")
            
            
        }
    }
}
            

private func createSession (account: String, token: String) {
    
    let urlFromMap = getUrl(selectUser:userCat, selectUrl:"createSession")
    
    guard let url = URL(string: urlFromMap) else { return }
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue(account, forHTTPHeaderField: "X-Account")
    urlRequest.httpMethod = "POST"
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let sessionID = json["session_id"] as? String {

            session = sessionID
            
            UserDefaults.standard.set(account, forKey: account_pref)
            UserDefaults.standard.set(sessionID, forKey: session_pref)
            
            
            DispatchQueue.main.async {
                
            
                startSession (account: account, sessionID: sessionID, token: token)
                
            }
            
        } else if error != nil {
            
            DispatchQueue.main.async {
                
               print ("created_session_error")
            }
        }
    }.resume()
}

private func startSession (account: String, sessionID: String, token: String) {
    
    let urlFromMap = getUrl(selectUser:userCat, selectUrl:"startSession")
    
    guard let url = URL(string: urlFromMap) else { return }
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue(account, forHTTPHeaderField: "X-Account")
    urlRequest.addValue(sessionID, forHTTPHeaderField: "X-Session-Id")
    urlRequest.httpMethod = "POST"
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
       
        var getToken: String? { return UserDefaults.standard.object(forKey: token_pref) as? String }
        
        
        if data != nil {
            
                session = sessionID
                
            if getToken != nil {
            
                subscribePush (account: account, sessionID: sessionID, token: getToken ?? "")
                
            }
            
            else {
                
                subscribePush (account: account, sessionID: sessionID, token: token)
            }

        
        } else if error != nil {
            
            DispatchQueue.main.async {
                
            }
        }
        
    }.resume()
}


private func subscribePush (account: String, sessionID: String, token: String) {
    

    print("in subscribePush ")
    print("\(account), \(token), \(sessionID)")
    
    let urlFromMap = getUrl(selectUser:userCat, selectUrl:"subscribePush")
    
    guard let url = URL(string: urlFromMap) else { return }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.addValue(account, forHTTPHeaderField: "X-Account")
    urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
    urlRequest.addValue(sessionID, forHTTPHeaderField: "X-Session-Id")
    
    let json: [String: Any] = ["sessionId": sessionID, "token": token, "os": "ios"]
    
    let jsonData = try? JSONSerialization.data(withJSONObject: json)
    urlRequest.httpBody = jsonData
     
    
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if data != nil {
            
            
            DispatchQueue.main.async {
  
                let status = LibInitStatus()
                let _ = LibInitObserver (object: status)
                status.statusName = "init"
            }
            
        } else if error != nil {
            
            DispatchQueue.main.async {
                
            }
        }
        
    }.resume()
    
}


public func addContact (subscriberInfo: [String:Any]) {

    contactInfo = subscriberInfo
    
    do {
        
            JSONSerialization.isValidJSONObject(subscriberInfo)
      
            let json = try? JSONSerialization.data(withJSONObject: subscriberInfo, options: [])
                      
    DispatchQueue.main.async {

        guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"subscribe"), json, account: account, session: session) else { return }
        
        
        if (libraryInit) {
            
            
            print ("libraryInit")
            
            URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
                if data != nil {
                    
                    print("new_contact_add_to_servise")
                    
                    do {
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                    }
                    
                } else if error != nil {
                    DispatchQueue.main.async {
                        
                    }
                }
            }.resume()
        }
        
        else {
            
            print ("nolibraryInit")
            let status = AddContactRequestStatus()
            let _ = AddContactRequestObserver(object: status)
            status.status = "request"
            
            
      }
    }
  }
}
 

 func prepareRequest(_ method: String, _ url: String, _ body: Data?, account: String, session: String) -> URLRequest?{
    
    let account = account
    let session = session
    let url = URL(string: url)
    var urlRequest = URLRequest(url:url!)
    urlRequest.httpMethod = method
    urlRequest.addValue(account, forHTTPHeaderField: "X-Account")
    urlRequest.addValue(session, forHTTPHeaderField: "X-Session-Id")
    urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
    urlRequest.httpBody = body
    return urlRequest
    
}


public struct Product {
    public var id: String
    public var categoryId: String?
    public var count: Int?
    public var price: String?
    public var picture: String?
    public var fields: [String:Any]?
}


func TrackingMapBilder(_ product: Product) -> [String:Any] {
    var productMap = [String:Any]()
    
    productMap["productId"] = product.id
  
    
    if product.categoryId != nil {
        productMap["categoryId"] = product.categoryId
    }
    
    if product.count != nil {
        productMap["count"] = product.count
    }
    
    if product.price != nil {
        productMap["price"] = product.price
    }
    
    if product.picture != nil {
        productMap["picture"] = product.picture
    }
    
    if product.fields != nil {
    
        for (key, _) in product.fields! {
            
            productMap[key] = product.fields?[key]
            
        }
    }

    return productMap
}


public func AddToFavourite (product: Product) {
    
    var map = TrackingMapBilder(product)
    
    map ["action"] = "productLike"
    
    let lastUpdate = Int(Date().timeIntervalSince1970)
    
    let wishlist: [String:Any] = ["products":map["productId"] ?? "", "lastUpdate": lastUpdate]

    let history: [[String:Any]] = [map]
    
    let json: [String : Any] = ["wishlist": wishlist, "history": history]
    
    do {
        
        guard JSONSerialization.isValidJSONObject(json) else {
            throw TrackerErr.invalidJson
        }
        
        let requestBody = try JSONSerialization.data(withJSONObject: json)

    guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"favourite"), requestBody, account: account, session: session) else { return }

    URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
        
        if data != nil {
            
       
            DispatchQueue.main.async {
            }
            
            } else if error != nil {
            DispatchQueue.main.async {
           
            }
        }
        
    }.resume()
        
    } catch {
        
       print("Error AddToFavourite")
}
}


public func RemoveFromFavourite (product: Product) {
    
    var map = TrackingMapBilder(product)
    
    map ["action"] = "productDislike"
    
    let lastUpdate = Int(Date().timeIntervalSince1970)
    
    let wishlist: [String:Any] = ["products":map["productId"] ?? "", "lastUpdate": lastUpdate]

    let history: [[String:Any]] = [map]
    
    let json: [String : Any] = ["wishlist": wishlist, "history": history]
    
    
    do {
        
        guard JSONSerialization.isValidJSONObject(json) else {
            throw TrackerErr.invalidJson
        }
        let requestBody =  try JSONSerialization.data(withJSONObject: json)
                      

    guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"favourite"), requestBody, account: account, session: session) else { return }

    URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
        if data != nil {
            
   
            DispatchQueue.main.async {
               
            
            }
        } else if error != nil {
            DispatchQueue.main.async {
           
            }
        }
    }.resume()
        
    } catch {
        
       print("Error RemoveFromFavourite")
}
}

public func AddToCart (product: Product) {
    
    var map = TrackingMapBilder(product)
    
    map ["action"] = "productAdd"
    
    let lastUpdate = Int(Date().timeIntervalSince1970)
    
    let cart: [String:Any] = ["lastUpdate": lastUpdate, "products": [["productId": map["productId"]]]]

    let history: [[String:Any]] = [map]
    
    let json: [String : Any] = ["cart": cart, "history": history]
    
    do {
        
        guard JSONSerialization.isValidJSONObject(json) else {
            throw TrackerErr.invalidJson
        }

        let requestBody =  try JSONSerialization.data(withJSONObject: json)
                      
    guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"cart"), requestBody, account: account, session: session) else { return }

    URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
        if data != nil {
            
            
            DispatchQueue.main.async {
               
               
            }
        } else if error != nil {
            DispatchQueue.main.async {
           
            }
        }
    }.resume()
    } catch {
        
       print("Error AddToCart")
}
}


public func RemoveFromCart (product: Product) {
    
    
    var map = TrackingMapBilder(product)
    
    map ["action"] = "productRemove"
    
    let lastUpdate = Int(Date().timeIntervalSince1970)
    
    let cart: [String:Any] = ["lastUpdate": lastUpdate, "products": [["productId": map["productId"]]]]

    let history: [[String:Any]] = [map]
    
    let json: [String : Any] = ["cart": cart, "history": history]
    

    do {
        
        guard JSONSerialization.isValidJSONObject(json) else {
            throw TrackerErr.invalidJson
            
        }
        
        let requestBody = try JSONSerialization.data(withJSONObject: json)


    guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"cart"), requestBody, account: account, session: session) else { return }

    URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
        if data != nil {
            
       
            DispatchQueue.main.async {
               
            
            }
        } else if error != nil {
            DispatchQueue.main.async {
           
            }
        }
    }.resume()
        
} catch {

print("Error RemoveFromCart")
    
}
}


public func ProductOpen (product: Product) {
    
    
    var map = TrackingMapBilder(product)
    
    map ["action"] = "productOpen"
      
    let lastUpdate = Int(Date().timeIntervalSince1970)
    
    let product = ["id": map["productId"] ?? "", "lastUpdate": lastUpdate]
    let params: [String:Any] = map
    
    let json: [String : Any] = ["product": product, "params": params]
    

    do {

        let requestBody =   try JSONSerialization.data(withJSONObject: json)
        guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"productOpen"), requestBody, account: account, session: session) else { return }
      


    URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
        if data != nil {
            
           
            DispatchQueue.main.async {
               
                
            }
        } else if error != nil {
            DispatchQueue.main.async {
           
            }
        }
    }.resume()
        
    } catch {
        
    print("Error ProductOpen")
        
  }
}

public struct Order {
    
    public var orderId: String?
    public var productId: String
    public var count: Int?
    public var price: String?
    public var picture: String?
    public var sum: Double? //сумма всей покупки
    public var fields: [String:Any]?
   
}


func buyMapBilder(_ order: Order) -> [String:Any] {
    
    var orderMap = [String:Any]()
    
    orderMap["orderId"] = order.orderId
    orderMap["productId"] = order.productId
    
    
    if order.count != nil {
        orderMap["count"] = order.count
    }
    
    if order.price != nil {
        orderMap["price"] = order.price
    }
    
    if order.picture != nil {
        orderMap["picture"] = order.picture
    }
    
    if order.sum != nil {
        orderMap["sum"] = order.sum
    }

    if order.fields != nil {
        
        
        for (key, _) in order.fields! {
            
            orderMap[key] = order.fields?[key]
            
        }
    }
 
    return orderMap
}


public func productBuy (order: Order) {
    
    var order = order

    if order.orderId == "" || order.orderId == nil { order.orderId = UUID().uuidString.lowercased() }
    
    var orderInfo = [String:Any]()

    var orderFields = [String:Any]()
    if order.fields != nil {
        for (k, v) in order.fields! {
            orderFields[k] = v
        }
    }
    if order.sum != nil { orderFields["sum"] = String(format: "%.2f", order.sum!) }
    if order.price != nil { orderFields["price"] = String(format: "%.2f", order.price!) }

    orderInfo["items"] = buyMapBilder(order)
    if !orderFields.isEmpty {
        orderInfo["order"] = orderFields
    }

    let json = ["orderId": order.orderId as Any,
                "orderInfo": orderInfo] as [String : Any]

    do {
        
        guard JSONSerialization.isValidJSONObject(json) else {
            throw TrackerErr.invalidJson
        }
        
        let requestBody =  try JSONSerialization.data(withJSONObject: json)
                      
 
    guard let urlRequest = prepareRequest("POST", getUrl(selectUser:userCat, selectUrl:"productBuy"), requestBody, account: account, session: session) else { return }

    URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
        if data != nil {
            DispatchQueue.main.async {
            
            }
        } else if error != nil {
            DispatchQueue.main.async {
             
            }
        }
    }.resume()
        
    } catch {
        
       print("Error productBuy")
   }
}


 public func clickPush (pd: [String:Any]){
    let urlFromMap = getUrl(selectUser:userCat, selectUrl:"clickPush")
    guard let url = URL(string: urlFromMap) else { return }
    let account = account
    let session = session
    
    print(account)
    
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue(account, forHTTPHeaderField: "X-Account")
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
    urlRequest.httpMethod = "POST"
    
    let data = pd //as! PushData
    
    let json: [String: Any] = ["sessionId": session, "personId": Int(data["personId"] as! String) ?? 0, "messageId": Int(data["messageId"] as! String) ?? -1, "intent": Int(data["intent"] as! String) ?? 2, "url": data["url"]as! String]
    //if let urlString = data["url"] { json["url"] = urlString }
    
    let jsonData = try? JSONSerialization.data(withJSONObject: json)
    urlRequest.httpBody = jsonData
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if data != nil {
            
            //print(json)
            
        } else if error != nil {
            
        }
    }.resume()
}

public func pushClickAction (userInfo: [AnyHashable : Any], Identifier: String) {

    let intent_0 = (userInfo[AnyHashable("intent_0")] as? String)
    let intent_1 = (userInfo[AnyHashable("intent_1")] as? String)
    let intent_2 = (userInfo[AnyHashable("intent_2")] as? String)
    let intent_3 = (userInfo[AnyHashable("intent_3")] as? String)
  
    let url_0 = (userInfo[AnyHashable("url")] as? String)
    let url_1 = (userInfo[AnyHashable("url_1")] as? String)
    let url_2 = (userInfo[AnyHashable("url_2")] as? String)
    let url_3 = (userInfo[AnyHashable("url_3")] as? String)
    

    
    func intentAction (Identifier: String) {
        
        if Identifier == "com.apple.UNNotificationDefaultActionIdentifier" {
             
            var dataForPushClick = [String: Any]()
            
            dataForPushClick = [
              
              "personId": userInfo[AnyHashable("personId")] ?? "0",
              "messageId": userInfo[AnyHashable("messageId")] ?? "0",
              "intent": intent_0 ?? "",
              "url": url_0 ?? ""
              
            ]
            
            clickPush (pd: dataForPushClick)
                              
            switch intent_0 {
                
            case "0":
                
                print("deep link")
                
            case "1":
              
                do {
                    if let url = URL(string: url_0 ?? ""), UIApplication.shared.canOpenURL(url) {
                        
                        UIApplication.shared.open(url)
                    }
                }
                 
            default:
                print("openApp")
   
            }
        }
        
        if Identifier == "button1" {
            
            var dataForPushClick = [String: Any]()
            
            dataForPushClick = [
              
              "personId": userInfo[AnyHashable("personId")] ?? "0",
              "messageId": userInfo[AnyHashable("messageId")] ?? "0",
              "intent": intent_1 ?? "",
              "url": url_1 ?? ""
              
            ]
            
            clickPush (pd: dataForPushClick)
         
            switch intent_1 {
                
            case "0":
                print("deep link")
                
            case "1":
                do {
                    if let url = URL(string: url_1 ?? ""), UIApplication.shared.canOpenURL(url) {
                        
                        UIApplication.shared.open(url)
                    }
                }
            default:
                print("openApp")
                
            }
        }
        if Identifier == "button2" {
            
            var dataForPushClick = [String: Any]()
            
            dataForPushClick = [
              
              "personId": userInfo[AnyHashable("personId")] ?? "0",
              "messageId": userInfo[AnyHashable("messageId")] ?? "0",
              "intent": intent_2 ?? "",
              "url": url_2 ?? ""
              
            ]
            
            clickPush (pd: dataForPushClick)
         
            switch intent_2 {
            case "0":
                print("deep link")
            case "1":
                do {
                    if let url = URL(string: url_2 ?? ""), UIApplication.shared.canOpenURL(url) {
                        
                        UIApplication.shared.open(url)
                    }
                }
            default:
                print("openApp")
                
            }
        }
        
        if Identifier == "button3" {
            
            var dataForPushClick = [String: Any]()
            
            dataForPushClick = [
              
              "personId": userInfo[AnyHashable("personId")] ?? "0",
              "messageId": userInfo[AnyHashable("messageId")] ?? "0",
              "intent": intent_3 ?? "",
              "url": url_3 ?? ""
              
            ]
            
            clickPush (pd: dataForPushClick)
         
            switch intent_3 {
                
            case "0":
                print("deep link")
            case "1":
                do {
                    if let url = URL(string: url_3 ?? ""), UIApplication.shared.canOpenURL(url) {
                        
                        UIApplication.shared.open(url)
                    }
                }
            default:
                print("openApp")
                
            }
        }
    }
    
   intentAction (Identifier: Identifier)
    
}

public func devSwitch () {
    
    userCat = "dev"
    
}

class LibInitStatus: NSObject {
    
    @objc dynamic var statusName = "no_init"
     
}

class LibInitObserver: NSObject {
            @objc var status: LibInitStatus
    var observation: NSKeyValueObservation?
    
    init(object: LibInitStatus) {
        self.status = object
        super.init()
        
        observation = observe(\.status.statusName, options: [.old, .new], changeHandler: { object, change in
            
            libraryInit = true
            
            if (addContactRequest) {
                
                addContact(subscriberInfo:contactInfo)
                
                
                }
            })
        }
    }


class AddContactRequestStatus: NSObject {
    
    @objc dynamic var status = "no_request"
     
}


class AddContactRequestObserver: NSObject {
            @objc var status: AddContactRequestStatus
    var observation: NSKeyValueObservation?
    
    init(object: AddContactRequestStatus) {
        self.status = object
        super.init()
        
        observation = observe(\.status.status, options: [.old, .new], changeHandler: { object, change in
            
            addContactRequest = true
            
            
            })
        }
    }


enum TrackerErr : Error{
    case emptyProductId
    case notExistedProductId
    case emptyCart
    case emptyFavourite
    case emptyEmail
    case emptyEmailAndPhone
    case invalidJson
    case badRequest
    case emptyProducts
    case alreadyLoggedIn
    case emptySession
}



