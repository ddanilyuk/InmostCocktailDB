//
//  CoctailTableViewCell.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit

class CoctailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkImageViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var drinkName: UILabel!
    
    var drinkImageURL: URL? {
        didSet {
            updateImage()
        }
    }
    
    override func prepareForReuse() {
        drinkImageView.image = nil
    }

    
    func updateImage() {
        self.drinkImageViewActivityIndicator.startAnimating()
        
        if let cachedImage = imageCache.object(forKey: "\(drinkImageURL?.absoluteString ?? "")" as NSString)  {
            drinkImageView.image = cachedImage
            self.drinkImageViewActivityIndicator.stopAndHide()
        } else {
            drinkImageView.loadImage(withUrl: "\(drinkImageURL?.absoluteString ?? "")", addImageToCache: true) {
                self.drinkImageViewActivityIndicator.stopAndHide()
            }
        }
    }
    
    
    override func layoutSubviews() {
        drinkImageView.layer.cornerRadius = 8
        drinkImageView.layer.masksToBounds = true
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
