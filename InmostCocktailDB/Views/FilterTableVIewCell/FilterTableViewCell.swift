//
//  FilterTableViewCell.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


//protocol FilterTableViewCellDelegate {
//    func userChangeFilterCell(with category: Category?, isCategorySelected: Bool)
//}


class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var filterCheckmarkButton: UIButton!
    
    var isCategorySelected: Bool = false {
        didSet {
            if isCategorySelected {
                filterCheckmarkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            } else {
                filterCheckmarkButton.setImage(UIImage(), for: .normal)
            }
        }
    }
    
//    var delegate: FilterTableViewCellDelegate?
    
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
    
    @IBAction func didPressFilterCheckmarkButton(_ sender: UIButton) {
        
//        isCategorySelected.toggle()
        
                
//        delegate?.userChangeFilterCell(with: category, isCategorySelected: isCategorySelected)
    }
    
}
