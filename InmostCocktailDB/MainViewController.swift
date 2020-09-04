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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
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
    
    @IBAction func didPressShowFilter(_ sender: UIButton) {
        guard let filterViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: FilterViewController.identifier) as? FilterViewController else { return }
        filterViewController.delegate = self
        filterViewController.selectedCategories = categories
        navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData[section].category.strCategory
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoctailTableViewCell.identifier, for: indexPath) as? CoctailTableViewCell else { return UITableViewCell() }
        
        let drink = tableViewData[indexPath.section].drinks[indexPath.row]
        
        cell.drinkName.text = drink.strDrink
        if let imageURL = drink.strDrinkThumb {
            cell.drinkImageURL = URL(string: imageURL)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
                            self?.tableViewData.append((category: Category(strCategory: category.strCategory), drinks: serverResponse.drinks))
                            print("*****")
                            print("LOG: \(serverResponse.drinks.count) drinks from category \(category.strCategory) downloaded!!!")
                            print("*****")

                            self?.tableView.reloadData()
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

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = scrollView.contentOffset
//        let bounds = scrollView.bounds
//        let size = scrollView.contentSize
//        let inset = scrollView.contentInset
//        let y = offset.y + bounds.size.height - inset.bottom
//        let h = size.height
//        let reload_distance:CGFloat = 10.0
//        if y > (h + reload_distance) {
//            print("updating")
//            
//            let isAlreadyDownLoaded = tableViewData.contains { (category, _) -> Bool in
//                return categories.contains(category)
//            }
////            print("isAlreadyDownLoaded", isAlreadyDownLoaded)
//            
//            guard categories.count >= tableViewData.count else {
//                return
//            }
//            
//            let category = categories[tableViewData.count]
//            if !isAlreadyDownLoaded {
//                api.getDataFromServer(requestType: RequestType.drinks, drinkNames: category.strCategory) { [weak self] data in
//                    let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
//                    if let serverResponse = serverResponse {
//                        DispatchQueue.main.async {
//                            self?.tableViewData.append((category: Category(strCategory: category.strCategory), drinks: serverResponse.drinks))
//                            self?.tableViewData.sort(by: { part1, part2 in
//                                return part1.category.strCategory < part2.category.strCategory
//                            })
//                            self?.tableView.reloadData()
//                        }
//                    }
//                }
//            }
//
//        }
//    }
}



extension MainViewController: FilterViewControllerDelegate {
    
    func filtersDidChanged(categories: [Category]) {
        self.categories = categories
        self.settings.selectedCategories = categories
    }
    
}
