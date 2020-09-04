//
//  FilterViewController.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit


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
        self.tableView.reloadData()
        
        if settings.allCategories.isEmpty {
            api.getDataFromServer(requestType: .categories, drinkNames: nil)  { [weak self] data in
                let serverResponse = try? JSONDecoder().decode(ServerResponse<Category>.self, from: data)
                if let serverResponse = serverResponse {
                    DispatchQueue.main.async {
                        self?.categories = serverResponse.drinks
                        self?.settings.allCategories = serverResponse.drinks
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {
            self.categories = settings.allCategories
        }

        
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: FilterTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: FilterTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func didPressApply(_ sender: UIButton) {
        delegate?.filtersDidChanged(categories: selectedCategories)
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
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

