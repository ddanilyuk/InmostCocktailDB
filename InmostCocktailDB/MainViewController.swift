//
//  ViewController.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var drinks: [Drink] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        api.getDataFromServer(requestType: RequestType.drinks ,drinkNames: ["Ordinary Drink"]) { [weak self] data in
            let serverResponse = try? JSONDecoder().decode(ServerResponse<Drink>.self, from: data)
            if let serverResponse = serverResponse {
                DispatchQueue.main.async {
                    self?.drinks = serverResponse.drinks
                    self?.tableView.reloadData()
                }
            }
        }
        
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: CoctailTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: CoctailTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func didPressShowFilter(_ sender: UIButton) {
        guard let filterViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: FilterViewController.identifier) as? FilterViewController else { return }
        
        navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoctailTableViewCell.identifier, for: indexPath) as? CoctailTableViewCell else { return UITableViewCell() }
        
        let drink = drinks[indexPath.row]
        
        cell.drinkName.text = drink.strDrink
        if let imageURL = drink.strDrinkThumb {
            cell.drinkImageURL = URL(string: imageURL)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
