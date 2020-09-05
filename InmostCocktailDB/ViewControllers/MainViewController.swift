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
    
    let settings = SettingsSingleton()
    
    /// Searching
    var isSearching: Bool = false
    let search = UISearchController(searchResultsController: nil)
    var tableViewDataFiltered: [(category: Category, drinks: [Drink])] = []

    /// Array of categories which start loading first category
    var categories: [Category] = [] {
        didSet {
            tableViewData = []
            guard categories.count > 0 else {
                print("LOG: No categories!")
                return
            }
            print("LOG: First category start downloading!!!")
            let category = categories[0]
            api.getDataFromServer(requestType: RequestType.drinks, drinkName: category.strCategory) { [weak self] data in
                let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
                if let serverResponse = serverResponse {
                    DispatchQueue.main.async {
                        print("LOG: First category downloaded!!!")
                        if !(self?.tableViewData.contains(where: {$0.category == category}) ?? true) {
                            self?.stopLoading()
                            self?.cachingImages(drinks: serverResponse.drinks)
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
        startLoading(with: "Loading drinks...")
        
        setupFirstLaunch()
        
        categories = settings.selectedCategories

        print("LOG: categories - ", categories.map( {$0.strCategory} ))
    }

    /// Table view settings.
    /// Registering cell
    private func setupTableView() {
        tableView.register(UINib(nibName: CoctailTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: CoctailTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Search bar settings.
    /// All search logic in extension of this file.
    private func setupSearch() {
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Search drinks"
        search.hidesNavigationBarDuringPresentation = true
        search.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = search
    }
    
    /// Technical task state that at startup you need to activate all the values in the filter.
    /// This function saves all possible filters to the userDefaults and immediately uses them.
    private func setupFirstLaunch() {
        if !settings.isFirstLaunch {
            startLoading(with: "Loading categories...")
            
            api.getDataFromServer(requestType: .categories, drinkName: nil)  { [weak self] data in
                let serverResponse = try? JSONDecoder().decode(ServerResponse<Category>.self, from: data)
                if let serverResponse = serverResponse {
                    DispatchQueue.main.async {
                        self?.stopLoading()
                        self?.settings.selectedCategories = serverResponse.drinks
                        self?.settings.allCategories = serverResponse.drinks
                        self?.categories = serverResponse.drinks
                        self?.tableView.reloadData()
                    }
                }
            }
            settings.isFirstLaunch = true
        }
    }
    
    private func startLoading(with text: String = "Loading...") {
        viewWithActivityIndicator.isHidden = false
        mainActivityIndicator.startAndShow()
        tableView.isHidden = true
        loadingLabel.text = text
    }
    
    private func stopLoading() {
        viewWithActivityIndicator.isHidden = true
        mainActivityIndicator.stopAndHide()
        tableView.isHidden = false
    }
    
    @IBAction func didPressShowFilter(_ sender: UIButton) {
        guard let filterViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: FilterViewController.identifier) as? FilterViewController else { return }
        filterViewController.delegate = self
        filterViewController.selectedCategories = categories
        navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    /// Caching image when new category downloaded.
    func cachingImages(drinks: [Drink]) {
        for drink in drinks {
            if let url = URL(string: drink.strDrinkThumb ?? "") {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let contensOfUrl = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: contensOfUrl) {
                                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                            }
                        }
                    }
                }
            }
        }
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
        return isSearching ? tableViewDataFiltered[section].category.strCategory : tableViewData[section].category.strCategory
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? tableViewDataFiltered.count : tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? tableViewDataFiltered[section].drinks.count : tableViewData[section].drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoctailTableViewCell.identifier, for: indexPath) as? CoctailTableViewCell else { return UITableViewCell() }
        
        let drink = isSearching ? tableViewDataFiltered[indexPath.section].drinks[indexPath.row] : tableViewData[indexPath.section].drinks[indexPath.row]
        
        cell.drinkNameLabel.text = drink.strDrink
        if let imageURL = drink.strDrinkThumb {
            cell.drinkImageURL = URL(string: imageURL)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /// When user tap in searching, application start to download all selected categorsies.
        guard !isSearching else { return }
        
        let isLastCellInSection = indexPath.row + 1 == tableViewData[indexPath.section].drinks.count
        print("LOG: Will display cell in \(indexPath). It is last cell? \(isLastCellInSection)!!!")

        if indexPath.section + 1 < categories.count  {
            
            let isAlreadyDownLoaded = tableViewData.contains { $0.category == categories[indexPath.section + 1] }
            
            if !isAlreadyDownLoaded, tableViewData.count != 0, isLastCellInSection {
                let category = categories[indexPath.section + 1]
                
                print("LOG: Downloading new section with category \(category.strCategory)!!!")

                api.getDataFromServer(requestType: RequestType.drinks, drinkName: category.strCategory) { [weak self] data in
                    let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
                    if let serverResponse = serverResponse {
                        DispatchQueue.main.async {
                            if !(self?.tableViewData.contains(where: {$0.category == category}) ?? true) {
                                
                                self?.tableViewData.append((category: Category(strCategory: category.strCategory), drinks: serverResponse.drinks))
                                self?.cachingImages(drinks: serverResponse.drinks)
                                
                                print("*****New Section*****")
                                print("LOG: \(serverResponse.drinks.count) drinks from category \(category.strCategory) downloaded!!!")
                                print("LOG: Start caching images for this section")
                                print("*********************")
                                
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
            tableViewDataFiltered = []
            isSearching = false
        } else {
            isSearching = true
        }
        
        if isSearching {
            
            /// This part of code start downloading all categories which are missing in `tableViewData`
            for i in tableViewData.count...categories.count {
                let category = categories[i - 1]
                api.getDataFromServer(requestType: RequestType.drinks, drinkName: category.strCategory) { [weak self] data in
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
            ///-----------
            
            /// Filter drinks which contains `lowerCaseSearchText` which user entered.
            tableViewDataFiltered = tableViewData.map { (category, drinks) -> (category: Category, drinks: [Drink]) in
                let filteredDrinks = drinks.filter { drink -> Bool in
                    drink.strDrink.lowercased().contains(lowerCaseSearchText)
                }
                return (category: category, drinks: filteredDrinks)
            }
        }
        
        /// Reload data after filtering
        tableView.reloadData()
    }
    
}
