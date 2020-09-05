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
    @IBOutlet weak var drinkNameLabel: UILabel!
    
    var drinkImageURL: URL? {
        didSet {
            updateImage()
        }
    }
    
    override func prepareForReuse() {
        drinkImageView.image = nil
        drinkImageURL = nil
        drinkImageViewActivityIndicator.startAndShow()
    }

    func updateImage() {
        self.drinkImageViewActivityIndicator.startAnimating()
        
        if let drinkImageURL = drinkImageURL {
            /// If image already cached, use if!
            if let cachedImage = imageCache.object(forKey: drinkImageURL.absoluteString as NSString)  {
                drinkImageView.image = cachedImage
                // print(self.drinkNameLabel.text, "using image from cache")
                self.drinkImageViewActivityIndicator.stopAndHide()
            } else {
                /// If not, download in and cache
                // print(self.drinkNameLabel.text, "downloading image")
                downloadAndCacheImage()
            }
        }
    }
    
    func downloadAndCacheImage() {
        if let url = drinkImageURL {
            drinkImageViewActivityIndicator.startAndShow()
            DispatchQueue.global(qos: .userInitiated).async {
                if let contensOfUrl = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        /// Checking if this cell need this image.
                        if url == self?.drinkImageURL {
                            if let image = UIImage(data: contensOfUrl) {
                                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                                self?.drinkImageView.image = image
                            }
                            self?.drinkImageViewActivityIndicator.stopAndHide()
                        }
                    }
                }
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
