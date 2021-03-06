//
//  OldDefectViewController.swift
//  MainTrack-Prototype
//
//  Created by Clay Suttner on 3/10/21.
//

import UIKit
import FirebaseAuth

class FeedViewController: UITableViewController {
    let repository = Repository.shared
    let searchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationController()
        loadDefectsForRole()
    }
    
    private func loadDefectsForRole() {
        repository.loadAllDefects { self.tableView.reloadData() }
    }
    
    private func configureNavigationController() {
        navigationController?.navigationBar.isHidden = false
        
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Table View
    
    private func configureTableView() {
        tableView.register(FeedCell.self)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.defects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(FeedCell.self)!
        let defect = repository.defects[indexPath.row]
        
        cell.configure(with: FeedCellViewModel(defect: defect))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            let detailViewController = segue.destination as! DetailViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let defect = repository.defects[indexPath.row]
                detailViewController.viewModel = DetailViewModel(defect: defect)
                detailViewController.readOnly = true
            } else {
                detailViewController.viewModel = DetailViewModel(defect: nil)
                detailViewController.readOnly = false
            }
        }
    }
}
