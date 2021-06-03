//
//  NewDefectViewController.swift
//  MainTrack-Prototype
//
//  Created by Clay Suttner on 6/3/21.
//

import UIKit

class NewDefectViewController: UITableViewController {
    let repository = Repository.shared
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationController()
        configureTableView()
    }
    
    private func configureNavigationController() {
        searchController.automaticallyShowsCancelButton = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureTableView() {
        tableView.register(AircraftCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.aircraft.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(AircraftCell.self)!
        let aircraft = repository.aircraft[indexPath.row]
        cell.configure(with: AircraftCellViewModel(aircraft: aircraft))
        return cell
    }
}