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
            drinkImageView.image = nil
            updateImage()
        }
    }

    
    func updateImage() {
        if let url = drinkImageURL {
            drinkImageViewActivityIndicator.startAndShow()
            
            DispatchQueue.global(qos: .userInitiated).async {
                let contensOfUrl = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if url == self?.drinkImageURL {
                        if let imageData = contensOfUrl {
                            self?.drinkImageView.image = UIImage(data: imageData)
                        } else {
                            self?.drinkImageView.image = UIImage(systemName: "photo")
                        }
                        self?.drinkImageViewActivityIndicator.stopAndHide()
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
