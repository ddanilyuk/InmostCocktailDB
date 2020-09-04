//
//  NetworkingAPI.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import Foundation


enum RequestType {
    case drinks
    case categories
}


class NetworkingAPI {
        
    typealias DataComplition = (Data) -> ()
    
    func getDataFromServer(requestType: RequestType, drinkNames: String?, complition: @escaping DataComplition) {
        
        var urlComponents = URLComponents()
        
        switch requestType {
        case .categories:
            
            let queryItems = [URLQueryItem(name: "c", value: "list")]
            guard let urlComponentsCategories = URLComponents(string: "https://www.thecocktaildb.com/api/json/v1/1/list.php") else {
                fatalError("urlComponentsCategories error")
            }
            urlComponents = urlComponentsCategories
            urlComponents.queryItems = queryItems

            
        case .drinks:
            let queryItems = [URLQueryItem(name: "c", value: drinkNames)]
            guard let urlComponentsDrinks = URLComponents(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php") else {
                fatalError("urlComponentsDrinks error")
            }
            urlComponents = urlComponentsDrinks
            urlComponents.queryItems = queryItems
        }
        
        
        guard let url = urlComponents.url else { return }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
//                let str = String(decoding: data, as: UTF8.self)
//                print(str)
                complition(data)
            }
            
        })
        dataTask.resume()
    }
    
}
