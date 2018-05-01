//
//  NotificationViewController.swift
//  Lenscape
//
//  Created by Thongrapee Panyapatiphan on 23/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    private var notifications: [NotificationItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        if let notifications = ArchiveUtil.loadNotifications() {
            self.notifications = notifications
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let notifications = ArchiveUtil.loadNotifications() {
            self.notifications = notifications
        }
    }
    
    @IBAction func clearNotifications(_ sender: UIButton) {
        ArchiveUtil.clearNotifications()
        notifications = []
        updateNotificationBadge()
    }
    
    @objc private func markAsRead(sender: UITapGestureRecognizerWithParam) {
        if let notification = sender.param as? NotificationItem {
            notifications.remove(at: notifications.index(of: notification)!)
            ArchiveUtil.saveNotifications(notifications: notifications)
            updateNotificationBadge()
            Api.retrievePhoto(photoId: Int(notification.photoId!)!).done { image in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
                vc.image = image
                self.present(vc, animated: true)
                }.catch { error in
                    let error = error as NSError
                    let message = error.userInfo["message"] as? String ?? ""
                    self.showAlertDialog(message: message)
            }

        }

    }
    
    private func updateNotificationBadge() {
        let unread = notifications.count
        navigationController?.tabBarItem.badgeValue = unread > 0 ? "\(unread)" : nil
        UIApplication.shared.applicationIconBadgeNumber = unread
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NotificationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Notifications", notifications.count)
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationViewCell", for: indexPath) as! NotificationTableViewCell
        let notification = notifications[indexPath.row]
        cell.title.text = notification.title
        cell.body.text = notification.body
//        cell.time.text = DateUtil.getShortenRelativeString(since: notification.deliveredTime!)
        addTapGesture(for: cell, with: #selector(markAsRead(sender:)), param: notification)
        
        return cell
    }
}
