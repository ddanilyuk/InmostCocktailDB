//
//  ViewController.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var viewWithActivityIndicator: UIView!
    
    var tableViewData: [(category: Category, drinks: [Drink])] = []
    
    var tableViewDataSorted: [(category: Category, drinks: [Drink])] = []

    
    let settings = SettingsSingleton()
    
    /// Searching
    var isSearching: Bool = false
    
    
    let search = UISearchController(searchResultsController: nil)
    
    var categories: [Category] = [] {
        didSet {
            tableViewData = []
            guard categories.count > 0 else {
                
                viewWithActivityIndicator.isHidden = false
                mainActivityIndicator.stopAndHide()
                loadingLabel.text = "You select no categories!\nPlease, select at least one!"
                tableView.isHidden = true
                
                print("LOG: User select no categories!")
                return
            }
            let category = categories[0]
            api.getDataFromServer(requestType: RequestType.drinks, drinkNames: category.strCategory) { [weak self] data in
                let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
                if let serverResponse = serverResponse {
                    DispatchQueue.main.async {
                        
                        print("LOG: First section downloaded!!!")
                        
                        if !(self?.tableViewData.contains(where: {$0.category == category}) ?? true) {
                            self?.mainActivityIndicator.stopAndHide()
                            self?.viewWithActivityIndicator.isHidden = true
                            self?.tableView.isHidden = false
                            
                            
                            self?.tableViewData.append((category: Category(strCategory: category.strCategory), drinks: serverResponse.drinks))
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearch()
        
        /// Start loading
        mainActivityIndicator.startAndShow()
        viewWithActivityIndicator.isHidden = false
        tableView.isHidden = true

        categories = settings.selectedCategories
        print("LOG: categories", categories.map( {$0.strCategory} ))
    }

    
    private func setupTableView() {
        tableView.register(UINib(nibName: CoctailTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: CoctailTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupSearch() {
        /// Search bar settings
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Search drinks"
        search.hidesNavigationBarDuringPresentation = true
        search.obscuresBackgroundDuringPresentation = false
//        search.obscuresBackgroundDuringPresentation = false
        
        self.navigationItem.searchController = search
//        self.navigationItem.hidesSearchBarWhenScrolling = true
        

//        definesPresentationContext = false
//        search.dimsBackgroundDuringPresentation = false
//        definesPresentationContext = true
        
    }
    
    @IBAction func didPressShowFilter(_ sender: UIButton) {
        guard let filterViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: FilterViewController.identifier) as? FilterViewController else { return }
        filterViewController.delegate = self
        filterViewController.selectedCategories = categories
        navigationController?.pushViewController(filterViewController, animated: true)
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearching ? tableViewDataSorted[section].category.strCategory : tableViewData[section].category.strCategory
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? tableViewDataSorted.count : tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? tableViewDataSorted[section].drinks.count : tableViewData[section].drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoctailTableViewCell.identifier, for: indexPath) as? CoctailTableViewCell else { return UITableViewCell() }
        
        let drink = isSearching ? tableViewDataSorted[indexPath.section].drinks[indexPath.row] : tableViewData[indexPath.section].drinks[indexPath.row]
        
        cell.drinkName.text = drink.strDrink
        if let imageURL = drink.strDrinkThumb {
            cell.drinkImageURL = URL(string: imageURL)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isSearching {
            return
        }
        let isLastCellInSection = indexPath.row + 1 == tableViewData[indexPath.section].drinks.count
        print("LOG: Will display cell in \(indexPath). It is last cell? \(isLastCellInSection)!!!")

        if indexPath.section + 1 < categories.count, tableViewData.count != 0, isLastCellInSection  {
            let isAlreadyDownLoaded = tableViewData.contains { (category, _) -> Bool in
                return category == categories[indexPath.section + 1]
            }
            
            if !isAlreadyDownLoaded {
                let category = categories[indexPath.section + 1]
                
                print("LOG: Downloading new section with category \(category.strCategory)!!!")

                api.getDataFromServer(requestType: RequestType.drinks, drinkNames: category.strCategory) { [weak self] data in
                    let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
                    if let serverResponse = serverResponse {
                        DispatchQueue.main.async {
                            if !(self?.tableViewData.contains(where: {$0.category == category}) ?? true) {
                                self?.tableViewData.append((category: Category(strCategory: category.strCategory), drinks: serverResponse.drinks))
                                print("*****")
                                print("LOG: \(serverResponse.drinks.count) drinks from category \(category.strCategory) downloaded!!!")
                                print("*****")
                                self?.tableView.reloadData()
                                
                            }
                        }
                    }
                }
            }
        } else {
            print("LOG: There is no other categories!!!")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



extension MainViewController: FilterViewControllerDelegate {
    
    func filtersDidChanged(categories: [Category]) {
        self.categories = categories
        self.settings.selectedCategories = categories
    }
}


extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        let lowerCaseSearchText = searchText.lowercased()
        
        if lowerCaseSearchText == "" {
            tableViewDataSorted = []
            isSearching = false
        } else {
            isSearching = true
        }
        
        if isSearching {
            for i in tableViewData.count...categories.count {
                let category = categories[i - 1]
                api.getDataFromServer(requestType: RequestType.drinks, drinkNames: category.strCategory) { [weak self] data in
                    let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
                    if let serverResponse = serverResponse {
                        DispatchQueue.main.async {
                            if !(self?.tableViewData.contains(where: {$0.category == category}) ?? true) {
                                self?.tableViewData.append((category: Category(strCategory: category.strCategory), drinks: serverResponse.drinks))
                                self?.tableView.reloadData()
                                self?.updateSearchResults(for: self?.search ?? UISearchController())
                            }
                        }
                    }
                }
            }
            

            tableViewDataSorted = tableViewData.map { (category, drinks) -> (category: Category, drinks: [Drink]) in
                let filteredDrinks = drinks.filter { drink -> Bool in
                    drink.strDrink.lowercased().contains(lowerCaseSearchText)
                }
                return (category: category, drinks: filteredDrinks)
            }
        }
        tableView.reloadData()
    }
}
