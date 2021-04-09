//
//  OldDefectViewController.swift
//  MainTrack-Prototype
//
//  Created by Clay Suttner on 3/10/21.
//

import UIKit
import FirebaseAuth

class OldDefectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let repository = Repository.shared
    let controller = DefectController.shared
    
    lazy var newDefectButton = ActionButton(title: "New Defect", color: .systemGreen, target: self, action: #selector(onNewDefectButtonTapped))
    lazy var profileItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(onProfileButtonTapped))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Defects"
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureNavigationController()
        loadDefectsForRole()
    }
    
    private func loadDefectsForRole() {
        if userData.role == .analyst {
            repository.loadAllDefects { self.tableView.reloadData() }
        } else {
            repository.loadDefects(for: userData.email) { self.tableView.reloadData() }
        }
    }
    
    private func configureNavigationController() {
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = profileItem
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        
        if userData.role == .analyst {
            navigationController?.isToolbarHidden = true
        } else {
            navigationController?.isToolbarHidden = false
            setToolbarItems(getSpacedButtonItems(with: [newDefectButton]), animated: true)
        }
    }
    
    @objc func onNewDefectButtonTapped() {
        controller.defect = nil
        controller.mode = .edit
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }
    
    @objc func onProfileButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
            repository.clearDefects()
        } catch let error {
            presentBasicAlert(title: "Error signing out", message: error.localizedDescription)
        }
    }

    // MARK: - Table View
    
    private func configureTableView() {
        tableView.register(DefectCell.self)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return repository.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.sections[section].defects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DefectCell.self)!
        cell.defect = repository.sections[indexPath.section].defects[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeader(title: repository.sections[section].title)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.defect = repository.sections[indexPath.section].defects[indexPath.row]
        controller.mode = .view
        navigationController!.pushViewController(DetailViewController(), animated: true)
    }
}