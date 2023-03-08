//
//  NetworkService.swift
//  Shopify App
//
//  Created by Zienab on 04/03/2023.
//

import Foundation
import Alamofire
protocol Service{
//    static func postCustomer(name: String,email: String , password: String)
    
    static  func postData<T: Codable>(endPoint : EndPoints,
                                      params: [String: Any],
                                      completionHandeler: @escaping ((T?), Error?,Int) -> Void)
    
    static func fetchFromApi<T: Decodable>( endPoint : EndPoints, complition: @escaping (T? ) -> Void)
    
}


private let Base_Url = "https://b24cfe7f0d5cba8ddb793790aaefa12a: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@mad-ios-2.myshopify.com/admin/api/2023-01/"

class NetworkService : Service{
    
    static  func postData<T: Codable>(endPoint : EndPoints, params: [String: Any], completionHandeler: @escaping ((T?), Error?,Int) -> Void){
        
        
        let path = "\(Base_Url)\(endPoint.path)"
        
        let url = URL(string: path)
        var urlRequst = URLRequest(url: url!)
        urlRequst.httpMethod = "post"
        urlRequst.httpShouldHandleCookies = false
        
        do{
            let requestBody = try JSONSerialization.data(withJSONObject: params,options: .prettyPrinted)
            urlRequst.httpBody = requestBody
            urlRequst.addValue("application/Json", forHTTPHeaderField: "content-type")
            
        }catch let error{
            debugPrint(error.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: urlRequst){ (data,response, error)  in
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let myData = try decoder.decode(T.self , from: data)
                    print(myData)
                    if let httpResponse = response as? HTTPURLResponse {
                        completionHandeler(myData, nil, httpResponse.statusCode)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    completionHandeler(nil, error, 0)
                }
            }
            
        }.resume()
        
    }
    
    static func fetchFromApi<T: Decodable>( endPoint : EndPoints, complition: @escaping (T? ) -> Void)  {
        
        let API_URL = "\(Base_Url)\(endPoint.path)"
        AF.request(API_URL).responseJSON { response in
            do
            {
                
                guard let responseData = response.data else {return}
                let result = try JSONDecoder().decode(T.self, from: responseData)
                //print(result)
                complition(result)
                
            }catch let error {
                complition(nil )
                print(error.localizedDescription)
                
            }
        }
    }
    
    // using url sesion
//    func loadDataFromURL<T: Decodable>( urlStr: String, completionHandeler: @escaping ((T?), Error?) -> Void){
//
//        let url = URL(string: urlStr)
//        guard let url = url else{ return }
//        let req = URLRequest(url: url)
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//        let task = session.dataTask(with: req) { data, response, error in
//
//            if let error = error{
//                completionHandeler(nil, error)
//            }else{
//                let res = try? JSONDecoder().decode(T.self, from: data!)
//                // print(res?.customers)
//                //                let movieArray = res?.items
//                completionHandeler(res, nil)
//            }
//
//        }
//        task.resume()
//    }
    
//    static  func postCustomer(name: String,email: String , password: String ){
//        let params: [String : Any] = [
//            "customer":[
//                "first_name": name,
//                "email" :email,
//                "note": password,
//
//            ]]
//
//
//
//        let url = URL(string: "https://b24cfe7f0d5cba8ddb793790aaefa12a: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@mad-ios-2.myshopify.com/admin/api/2023-01/customers.json" )
//
//        var urlRequst = URLRequest(url: url!)
//        urlRequst.httpMethod = "post"
//        urlRequst.httpShouldHandleCookies = false
//
//        do{
//            let requestBody = try JSONSerialization.data(withJSONObject: params,options: .prettyPrinted)
//            urlRequst.httpBody = requestBody
//            urlRequst.addValue("application/Json", forHTTPHeaderField: "content-type")
//
//        }catch let error{
//            debugPrint(error.localizedDescription)
//        }
//
//        URLSession.shared.dataTask(with: urlRequst){ (data,response, error)  in
//
//            if let data = data {
//
//                if let httpResponse = response as? HTTPURLResponse {
//                    if(httpResponse.statusCode == 201){
//                        do {
//                            let decoder = JSONDecoder()
//                            let myData = try decoder.decode(CustomerResponse.self, from: data)
//                            print(myData)
//                        } catch {
//                            print("Error decoding JSON: \(error)")
//                        }
//                    }else{
//                        do {
//                            let decoder = JSONDecoder()
//                            let myData = try decoder.decode(ErrorResponse.self, from: data)
//                            print(myData.errors!)
//                        } catch {
//                            print("Error decoding JSON: \(error)")
//                        }
//                    }
//                }
//
//            }
//
//
//        }.resume()
//
//    }
//

    
}