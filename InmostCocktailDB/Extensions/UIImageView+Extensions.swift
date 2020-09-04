//
//  UIImageView+Extensions.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit



extension UIImageView {
    /**
     Sets pictute to image view.
     - Parameters:
     - urlString: string with URL for get one breed by URL Request;
     - addImageToCache: true if need to add a picture to the cache.
     
     Shows activity indicator while the picture loads.
     */
    func loadImage(withUrl urlString : String, addImageToCache: Bool, complition: @escaping () -> ()) {
//        var imageStringUrl: String?
        self.image = nil
        
        // Sets activity Indicator
//        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.medium)
//        addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//
//        if addImageToCache {
//            activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y * 2.5)
//        } else {
//            activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y * 0.5)
//        }
        
        
        // Gets image
        let url = URL(string: urlString)!
        DispatchQueue.global(qos: .userInitiated).async {
            let contensOfUrl = try? Data(contentsOf: url)
            
            DispatchQueue.main.async {
                if let image = UIImage(data: contensOfUrl!) {
                    if addImageToCache {
                        imageCache.setObject(image, forKey: urlString as NSString)
                    }
                    self.image = image
                    complition()
//                    activityIndicator.removeFromSuperview()
                }
            }
        }
        
        
    }
    
}

