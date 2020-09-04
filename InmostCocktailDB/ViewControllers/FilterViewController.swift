//
//  FilterViewController.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


/// Delegate which return back after pop selected categories.
protocol FilterViewControllerDelegate {
    func filtersDidChanged(categories: [Category])
}


class FilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories: [Category] = []
    
    var selectedCategories: [Category] = []
    
    var delegate: FilterViewControllerDelegate?
    
    var settings = SettingsSingleton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.categories = settings.allCategories
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: FilterTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: FilterTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func didPressApply(_ sender: UIButton) {
        
        if selectedCategories.isEmpty {
            /// If user dont select any filter, present warning.
            let alert = UIAlertController(title: nil, message: "Plese, select at least one filter!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        delegate?.filtersDidChanged(categories: selectedCategories)

        self.navigationController?.popViewController(animated: true)
    }
    
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.identifier, for: indexPath) as? FilterTableViewCell else { return UITableViewCell() }
        
        let category = categories[indexPath.row]
        cell.category = category
        cell.isCategorySelected = selectedCategories.contains(where: { $0.strCategory == category.strCategory })

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterTableViewCell else { return }
        
        let isInSelectedCategories = selectedCategories.contains(where: { $0.strCategory == cell.category?.strCategory })
        
        if isInSelectedCategories {
            selectedCategories.removeAll(where: {$0.strCategory == cell.category?.strCategory})
        } else {
            selectedCategories.append(cell.category ?? Category(strCategory: ""))
        }
        
        cell.isCategorySelected = !isInSelectedCategories
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
