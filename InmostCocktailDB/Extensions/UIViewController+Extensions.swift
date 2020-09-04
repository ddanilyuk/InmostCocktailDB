//
//  UIViewController+Extensions.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


extension UIViewController {
    
    class var identifier: String {
        return String(describing: self)
    }
}
