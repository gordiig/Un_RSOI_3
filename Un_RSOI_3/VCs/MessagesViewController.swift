//
//  MessagesViewController.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 09.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import UIKit
import Combine

class MessagesViewController: UIViewController, AlertPresentable, ApiAlertPresentable {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    static let storyboardID = "MessagesVC"
    let refreshControl = UIRefreshControl()
    let messageManager = Message.objects
    private var valuesSubscriber: AnyCancellable!
    private var errorSubscriber: AnyCancellable!
    var messages = Message.objects.all {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        valuesSubscriber = messageManager.publisher.sink(receiveValue: { () in
            self.messages = self.messageManager.all
        })
        errorSubscriber = messageManager.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (err) in
                self.apiAlert(err)
            })
        updateMessages()
    }
    
    // MARK: - RefreshControl
    @objc func refreshControlValueChanged() {
        updateMessages()
    }
    
    // MARK: - Updating messages
    func updateMessages() {
        messageManager.fetchAll()
        refreshControl.endRefreshing()
    }
    
}


// MARK: - UITableViewDataSourse
extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.id) as? MessageTableViewCell else {
            return UITableViewCell()
        }
        cell.setUp(messages[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        guard let vc = storyboard?.instantiateViewController(identifier: MessageViewController.storyboardID) as? MessageViewController else {
            alert(title: "Can't instatiate MessageVC")
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
