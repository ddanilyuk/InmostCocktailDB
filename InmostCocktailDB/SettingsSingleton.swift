//
//  SettingsSingleton.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


public class SettingsSingleton {
    
    private var userDefaults = UserDefaults.standard
    
    static let shared = SettingsSingleton()
    
    
    var isFirstLaunch: Bool {
        get {
            return userDefaults.bool(forKey: "isFirstLaunch")
        }
        set {
            userDefaults.set(newValue, forKey: "isFirstLaunch")
        }
    }
    
    
    var selectedCategories: [Category] {
        get {
            let selectedCategoriesData = userDefaults.data(forKey: "selectedCategories") ?? Data()
            let categories = try? JSONDecoder().decode([Category].self, from: selectedCategoriesData)
            return categories != nil ? categories! : []
        }
        set {
            let selectedCategoriesData = try? JSONEncoder().encode(newValue)
            userDefaults.set(selectedCategoriesData, forKey: "selectedCategories")
        }
    }
    
    
    var allCategories: [Category] {
        get {
            let selectedCategoriesData = userDefaults.data(forKey: "allCategories") ?? Data()
            let categories = try? JSONDecoder().decode([Category].self, from: selectedCategoriesData)
            return categories != nil ? categories! : []
        }
        set {
            let selectedCategoriesData = try? JSONEncoder().encode(newValue)
            userDefaults.set(selectedCategoriesData, forKey: "allCategories")
        }
    }


}
