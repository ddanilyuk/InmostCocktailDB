//
//  FilterViewController.swift
//  InmostCocktailDB
//
//  Created by Денис Данилюк on 04.09.2020.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories: [Category] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
        
        api.getDataFromServer(requestType: .categories, drinkNames: nil)  { [weak self] data in
            let serverResponse = try? JSONDecoder().decode(ServerResponse<Category>.self, from: data)
            if let serverResponse = serverResponse {
                DispatchQueue.main.async {
                    self?.categories = serverResponse.drinks
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: FilterTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: FilterTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    @IBAction func didPressApply(_ sender: UIButton) {
    }
    
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.identifier, for: indexPath) as? FilterTableViewCell else { return UITableViewCell() }
        
        let category = categories[indexPath.row]
        
        
        
        return cell
    }
    
    
}


