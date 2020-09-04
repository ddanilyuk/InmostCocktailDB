//
//  FilterTableViewCell.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    var isCategorySelected: Bool = false {
        didSet {
            /// Using SF Symols
            checkmarkImageView.image = isCategorySelected ? UIImage(systemName: "checkmark") : UIImage()
        }
    }
        
    var category: Category? {
        didSet {
            filterNameLabel.text = category?.strCategory
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
