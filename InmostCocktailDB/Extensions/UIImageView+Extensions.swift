//
//  UIImageView+Extensions.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


extension UIImageView {

    func loadImage(withUrl urlString : String, addImageToCache: Bool, complition: @escaping () -> ()) {
        
        if let url = URL(string: urlString) {
            DispatchQueue.global(qos: .userInitiated).async {
                if let contensOfUrl = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: contensOfUrl) {
                            if addImageToCache {
                                imageCache.setObject(image, forKey: urlString as NSString)
                            }
                            self.image = image
                            complition()
                        }
                    }
                }
            }
        }
        
    }
    
}
