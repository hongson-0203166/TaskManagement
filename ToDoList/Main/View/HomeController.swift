//
//  ViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit
import SnapKit
import CoreData
import FirebaseAuth
import Reachability
import FirebaseFirestoreInternal
import EventKit
//import Reachability

class HomeController: UIViewController  {
    @IBOutlet weak var profileViewButton: UIButton!
    @IBOutlet weak var searchTaskTF: UITextField!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    
    var lableSection: UILabel?
    var sectionLabels: [Int: UILabel] = [:]
    var contentSection = ["All"]
    let sectionMenus: [Int: [String]] = [0: ["Today", "Week", "Month","All"] ]
    var viewModel = HomeViewModel()
   var reminderManager = ReminderManager()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        taskTableView.register(nib, forCellReuseIdentifier: "TaskTableViewCell")
        taskTableView.showsVerticalScrollIndicator = false
        taskTableView.rowHeight = UITableView.automaticDimension
        taskTableView.delegate = self
        taskTableView.dataSource = self
        checklogin()
        setSearchButton()
        
        
        
        //viewModel.safeEmail  = (UserDefaults.standard.string(forKey: "email") ?? "son").replacingSpecialCharacters()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskUpdated(_:)), name: .taskUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(syncPendingActions(_:)), name: .syncPendingActions, object: nil)
//            //viewModel.tasks = viewModel.fetchTasks()
//            print("Device is not connected to the internet.")
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
        //signout()
       //viewModel.deleteAllData()
       if NetworkMonitor.shared.isConnected{
            viewModel.syncPendingActions()
//           viewModel.synchronizeTasks { task in
//               self.viewModel.tasks = task.filter{ !$0.isdeleted }
//           }
           viewModel.synchronizeTasks { syncedTasks in
               // Sử dụng dữ liệu đã đồng bộ
               self.viewModel.tasks = syncedTasks
               if self.viewModel.tasks.count == 0{
                   self.emptyImageView.isHidden = false
               }else{
                   self.emptyImageView.isHidden = true
               }
               //   viewModel.filterTask()
               self.taskTableView.reloadData()
               print(syncedTasks)
           }
        }
        viewModel.tasks = viewModel.fetchTasks()
        DispatchQueue.main.async {
            if self.viewModel.tasks.count == 0{
                self.emptyImageView.isHidden = false
            }else{
                self.emptyImageView.isHidden = true
            }
            //   viewModel.filterTask()
            self.taskTableView.reloadData()
        }
     
        print(viewModel.tasks)
  
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print(UserDefaults.standard.string(forKey: "email"))
        checklogin()
        //viewModel.safeEmail  = (UserDefaults.standard.string(forKey: "email") ?? "").replacingSpecialCharacters()
        if NetworkMonitor.shared.isConnected{
             viewModel.syncPendingActions()
            viewModel.synchronizeTasks { syncedTasks in
                // Sử dụng dữ liệu đã đồng bộ
                self.viewModel.tasks = syncedTasks
                
                if self.viewModel.tasks.count == 0{
                    self.emptyImageView.isHidden = false
                }else{
                    self.emptyImageView.isHidden = true
                }
                self.taskTableView.reloadData()
            }
         }
       
        viewModel.tasks = viewModel.fetchTasks()
//
        
        DispatchQueue.main.async {
            if self.viewModel.tasks.count == 0{
                self.emptyImageView.isHidden = false
            }else{
                self.emptyImageView.isHidden = true
            }
            //   viewModel.filterTask()
            self.taskTableView.reloadData()
        }
        
        reminderManager.syncTasksWithReminders()
        print(viewModel.tasks)
        
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date) {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)

        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event created")
        } catch {
            print("Error saving event: \(error)")
        }
    }
    
    @objc func showOfflineDeviceUI(notification: Notification) {
        
        if NetworkMonitor.shared.isConnected {
            print("Connected")
       
                 viewModel.syncPendingActions()
                viewModel.synchronizeTasks { task in
                    self.viewModel.tasks = task
                }
             

            DispatchQueue.main.async {
                if self.viewModel.tasks.count == 0{
                    self.emptyImageView.isHidden = false
                }else{
                    self.emptyImageView.isHidden = true
                }
                //   viewModel.filterTask()
                self.taskTableView.reloadData()
            }
        } else {
            print("Not connected")
        }
    }
   @objc func syncPendingActions(_ notification: Notification){
       if NetworkMonitor.shared.isConnected{
            viewModel.syncPendingActions()
           viewModel.synchronizeTasks { task in
               self.viewModel.tasks = task.filter{ !$0.isdeleted }
           }
        }
       DispatchQueue.main.async {
           if self.viewModel.tasks.count == 0{
               self.emptyImageView.isHidden = false
           }else{
               self.emptyImageView.isHidden = true
           }
           //   viewModel.filterTask()
           self.taskTableView.reloadData()
       }
    }
              

    

    

    func checklogin(){
        
        if Auth.auth().currentUser != nil {
            let email = Auth.auth().currentUser?.email
            UserDefaults.standard.setValue(email, forKey: "email")
            print(email)
                print("User logged in")
              } else {
                  print("User")
                  let storyb = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                  let navi = UINavigationController(rootViewController:storyb)
                  navi.modalPresentationStyle = .fullScreen
                  present(navi, animated: true)
              }
    }
    
    @objc func handleTaskUpdated(_ notification: Notification) {
        viewModel.tasks = viewModel.fetchTasks()
       // viewModel.filterTask()
        if viewModel.tasks.count == 0 {
            emptyImageView.isHidden = false
        }else{
            emptyImageView.isHidden = true
        }
        taskTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setSearchButton(){
        // Tạo button cho leftView
        // Tạo button cho leftView
        let leftButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "search-normal"), for: .normal) // Sử dụng hình ảnh hệ thống
        leftButton.frame = CGRect(x: 8, y: 0, width: searchTaskTF.frame.height, height: searchTaskTF.frame.height) // Điều chỉnh kích thước của button nếu cần thiết
        leftButton.contentMode = .center
        leftButton.addTarget(self, action: #selector(searchHandle), for: .touchUpInside)
        
        // Tạo container view cho leftButton
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: searchTaskTF.frame.height + 8, height: searchTaskTF.frame.height)) // Điều chỉnh kích thước nếu cần thiết
        containerView.addSubview(leftButton)
        
        // Thiết lập button làm leftView của UITextField
        searchTaskTF.leftView = containerView
        searchTaskTF.leftViewMode = .always // Luôn hiển thị leftView
    
        // Thiết lập border cho UITextField
        searchTaskTF.layer.borderColor = UIColor(hexString: "979797")?.cgColor // Màu của border
        searchTaskTF.layer.borderWidth = 1.0 // Độ dày của border
        searchTaskTF.layer.cornerRadius = 5.0 // Bo góc của border nếu cần
        searchTaskTF.textColor = UIColor(hexString: "AFAFAF")
        searchTaskTF.delegate = self
        // Thiết lập placeholder với thuộc tính
        let placeholderText = "Search for your task..."
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray, // Màu của placeholder
            .font: UIFont.italicSystemFont(ofSize: searchTaskTF.font?.pointSize ?? 17) // Phông chữ của placeholder
        ]
        searchTaskTF.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
    }
    
    
    @objc func searchHandle(){
        print("\(contentSection[0])")
        let title = contentSection[0]
        let currentDate = Date()
         let search = searchTaskTF.text ?? ""
      
        switch title {
        case "Today":
            viewModel.tasks = viewModel.filterTasksByDate(viewModel.fetchTasks()) { viewModel.isDateInToday($0, currentDate: currentDate) }
            if search == "" {
                 viewModel.tasks = viewModel.tasks.filter { task in
                     if let taskTitle = task.title as? String {
                         return taskTitle.localizedCaseInsensitiveContains(search)
                     }
                     return false
                 }
             }
            
        case "Week":
            viewModel.tasks = viewModel.filterTasksByDate(viewModel.fetchTasks()) { viewModel.isDateInCurrentWeek($0, currentDate: currentDate) }
            if  search == "" {
                viewModel.tasks = viewModel.tasks
            }else{
                viewModel.tasks = viewModel.tasks.filter { task in
                    if let taskTitle = task.title as? String {
                        return taskTitle.localizedCaseInsensitiveContains(search)
                    }
                    return false
                }
            }
           
        case "Month":
            viewModel.tasks = viewModel.filterTasksByDate(viewModel.fetchTasks()) { viewModel.isDateInCurrentMonth($0, currentDate: currentDate) }
            if  search == "" {
                viewModel.tasks = viewModel.tasks
            }else{
                viewModel.tasks = viewModel.tasks.filter { task in
                    if let taskTitle = task.title as? String {
                        return taskTitle.localizedCaseInsensitiveContains(search)
                    }
                    return false
                }
            }
           
        case "All":
            viewModel.tasks = viewModel.fetchTasks()
            if  search == "" {
                viewModel.tasks = viewModel.tasks
            }else{
                viewModel.tasks = viewModel.tasks.filter { task in
                    if let taskTitle = task.title as? String {
                        return taskTitle.localizedCaseInsensitiveContains(search)
                    }
                    return false
                }
            }
           
        default:
            viewModel.tasks = viewModel.fetchTasks()
        }
        
        if viewModel.tasks.count == 0{
            emptyImageView.isHidden = false
        }else{
            emptyImageView.isHidden = true
        }
        taskTableView.reloadData()
    
    }
    
    @IBAction func filterButton(_ sender: UIButton) {
        showContextMenu1(sender, menu: ["Todo", "Complete"])
    }

    
    @IBAction func profileNaviHandle(_ sender: Any) {
        let vcProlfile = storyboard?.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        navigationController?.pushViewController(vcProlfile, animated: true)
    }
    

    private func updateLabelInSection(_ title: String, forSection section: Int) {
            contentSection[section] = title
            if let label = sectionLabels[section] {
                label.text = title
            }
           
            let currentDate = Date()
            switch title{
            case "Today":
                viewModel.tasks = viewModel.filterTasksByDate(viewModel.fetchTasks()) { viewModel.isDateInToday($0, currentDate: currentDate) }
                
            case "Week":
                viewModel.tasks = viewModel.filterTasksByDate(viewModel.fetchTasks()) { viewModel.isDateInCurrentWeek($0, currentDate: currentDate) }
            case "Month":
                viewModel.tasks = viewModel.filterTasksByDate(viewModel.fetchTasks()) { viewModel.isDateInCurrentMonth($0, currentDate: currentDate) }
            case "All":
                viewModel.tasks = viewModel.fetchTasks()
            default:
                viewModel.tasks = []
            }
        
        if viewModel.tasks.count == 0{
            emptyImageView.isHidden = false
        }else{
            emptyImageView.isHidden = true
        }
        
            taskTableView.reloadData()
        }
}


//MARK: -TableViewDelegate, Datasource
extension HomeController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else{
            return UITableViewCell()
        }
      
                cell.contentView.layer.borderWidth = 0
                cell.selectionStyle = .none
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
                
                let task = viewModel.tasks[indexPath.row]
    
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
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        constraintsHeader(section: contentSection[section], sectionIndex: section)
    }
    
    
    func constraintsHeader(section:String, sectionIndex: Int) -> UIView{
       let headerSectionView = UIView()
        headerSectionView.backgroundColor = .clear
        
        
        let headerSubView = UIView()
        headerSubView.backgroundColor = UIColor(hexString: "FFFFFF", alpha: 0.21)
        headerSubView.layer.cornerRadius = 4
        headerSubView.clipsToBounds = true
        headerSectionView.addSubview(headerSubView)
        
        
        lableSection = UILabel()
        lableSection?.text = section
        //lableSection?.tag = sectionIndex
        sectionLabels[sectionIndex] = lableSection
        lableSection?.textColor = .white
        headerSubView.addSubview(lableSection!)
        
        
        let image = UIImageView()
        image.image = UIImage(named: "arrow-down")
        image.contentMode = .center
        headerSubView.addSubview(image)
        
        let button = UIButton(type: .system)
        button.tag = sectionIndex
        button.addTarget(self, action: #selector(showContextMenu(_:)), for: .touchUpInside)
        headerSubView.addSubview(button)
        
        //constraint
        headerSubView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        lableSection?.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            
        }
        
        image.snp.makeConstraints { make in
            make.leading.equalTo(lableSection?.snp.trailing ?? 0).offset(4)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        button.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        return headerSectionView
    }

    @objc func showContextMenu(_ sender: UIButton){
        showContextMenu1(sender, menu: [""])
    }
    //MARK: -showContextMenu
     func showContextMenu1(_ sender: UIButton, menu:[String]) {
        let section = sender.tag
         var actions: [UIAction]
    
            let menuItems = sectionMenus[section] ?? ["bb"]
             actions = menuItems.map { item in
                        UIAction(title: item, handler: { _ in
                            self.updateLabelInSection(item, forSection: section)
                        })
                    }
       
                
                let menu = UIMenu(title: "", children: actions)
                sender.menu = menu
                sender.showsMenuAsPrimaryAction = true
                sender.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = viewModel.tasks[indexPath.row]
         let newEditVC = storyboard?.instantiateViewController(withIdentifier: "EditTaskViewController") as? EditTaskViewController
        newEditVC?.task = task
        newEditVC?.indexPathRow =  indexPath.row
        print(task)
        
        
        
        newEditVC?.taskClosure = { taskCompletion in
            print(taskCompletion)
            self.viewModel.updateTask(taskCompletion)
            tableView.reloadData()
        }
        
        
        let navigation = UINavigationController(rootViewController: newEditVC ?? UINavigationController())
        navigation.modalPresentationStyle = .fullScreen
                present(navigation, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
//                self.deleteTask(at: indexPath)
                let task = self.viewModel.tasks[indexPath.row]
                print(task)
                print(self.viewModel.tasks)
                self.viewModel.tasks.remove(at: indexPath.row)
                print(self.viewModel.tasks)
                tableView.reloadData()
                
                
                self.viewModel.deleteTask(task)
                
             print(self.viewModel.fetchTasks())
                
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension HomeController: UITextFieldDelegate{

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchHandle()
        return true
    }
}



        
