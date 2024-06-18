//
//  FocusViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit
import UserNotifications
import EventKit

class FocusViewController: UIViewController {
    
    @IBOutlet weak var noticeTableView: UITableView!
    let reminder = ReminderManager()
    var notice = [EKReminder]()
    var tasks = [Task]()
    var viewModel = HomeViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString:"FFFFFF", alpha: 0.87) ?? UIColor()]
        
        title = "Notification"
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        noticeTableView.register(nib, forCellReuseIdentifier: "TaskTableViewCell")
        
        loadRemindersAndTasks()
    }
    
    
    private func loadRemindersAndTasks() {
            reminder.fetchRemindersForCurrentDate { [weak self] reminders in
                guard let self = self else { return }
                self.notice = reminders
                self.tasks = self.viewModel.fetchTasks()
                self.filterTasks()
                DispatchQueue.main.async {
                    self.noticeTableView.reloadData()
                }
            }
        }
    
    private func filterTasks() {
           tasks = tasks.filter { task in
               notice.contains { reminder in
                   task.reminderIdentifier == reminder.calendarItemIdentifier
               }
           }
       }
}

extension FocusViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else{
            return UITableViewCell()
        }
      
                cell.contentView.layer.borderWidth = 0
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
                
        let task = self.tasks[indexPath.row]
    
                let title = task.title as? String
                let description = task.descrip as? String
                let selectPriorityforTask = task.priority as? String
                let status = task.status as? Bool
                let tag = task.tag as? String
                let color = task.colorCate as? String
                let date = task.date as? Date
                let imagecate = task.imagecate as? String
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd hh:mm a"
                let formattedTime = formatter.string(from: date ?? Date())
                
                cell.categoryImageView.image = UIImage(named: imagecate ?? "")
                cell.categoryName.text = tag ?? ""
                cell.imageandLableView.backgroundColor = UIColor(hexString: color ?? "")
                cell.flagNumberLable.text = selectPriorityforTask ?? ""
                cell.titleTask.text = title ?? ""
                cell.dateLable.text = "Create At \(formattedTime)"
                cell.imageStatus.image = status ?? false ? UIImage(named: "circle 1") : UIImage(named: "circle")
                 
        return cell
    }
    
    
}
