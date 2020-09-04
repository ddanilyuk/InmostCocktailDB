//
//  ServerResponse.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import Foundation


struct ServerResponse<T: Codable>: Codable {
    var drinks: [T]
}

//struct ArrayDataResponse<T: Decodable>: Decodable {
//    var drinks: [T]
//}

struct Drink: Codable {
    var strDrink: String
    var strDrinkThumb: String?
    var idDrink: String
}
