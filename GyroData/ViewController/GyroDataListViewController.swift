//
//  GyroDataListViewController.swift
//  GyroData
//
//  Created by kjs on 2022/09/16.
//

import UIKit

final class GyroDataListViewController: UIViewController {
    enum Section {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, GyroEntity>?
    
    private let gyroDataTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.register(GyroDataTableViewCell.self, forCellReuseIdentifier: GyroDataTableViewCell.identifier)
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        gyroDataTableView.delegate = self
        setUpView()
        configureGyroDataTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationBar()
        guard let data = CoreDataManager.shared.readTenPiecesOfData() else {
            print("데이터없음")
            return }
        createSnapshot(data)
    }

    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(gyroDataTableView)
      
        setUpGyroDataTableView()
    }
    
    private func setUpGyroDataTableView() {
        let safeArea = view.safeAreaLayoutGuide
        gyroDataTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gyroDataTableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            gyroDataTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            gyroDataTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            gyroDataTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    private func setUpNavigationBar() {
        let title = "목록"
        let measurement = "측정"
        let rightButtonItem = UIBarButtonItem(title: measurement,
                                              style: .plain,
                                              target: self, action: #selector(measurementButtonTapped))
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.title = title
        navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    @objc private func measurementButtonTapped() {
        let measureGyroDataViewController = MeasureGyroDataViewController()
        navigationController?.pushViewController(measureGyroDataViewController, animated: true)
    }
}

// MARK: DiffableDataSource
extension GyroDataListViewController {
    private func configureGyroDataTableView() {
        dataSource = UITableViewDiffableDataSource<Section, GyroEntity>(tableView: gyroDataTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GyroDataTableViewCell.identifier, for: indexPath) as? GyroDataTableViewCell else { return UITableViewCell() }
            
            cell.configureCell(with: itemIdentifier)
            return cell
        })
    }
    
    private func createSnapshot(_ data: [GyroEntity]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GyroEntity>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: UITableViewDelegate
extension GyroDataListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let play = "Play"
        let playAction = UIContextualAction(style: .normal, title: play) { _, _, _ in
            print("play")
        }
        playAction.backgroundColor = .systemGreen
        
        let delete = "Delete"
        let deleteAction = UIContextualAction(style: .normal, title: delete) { _, _, _ in
            print("delete")
        }
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [playAction, deleteAction])
    }
}
