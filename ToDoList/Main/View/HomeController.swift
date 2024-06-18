//
//  ViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit
import SnapKit
import CoreData

class HomeController: UIViewController  {
   
    @IBOutlet weak var menuShowOptionNaviButton: UIImageView!
    
    @IBOutlet weak var profileViewButton: UIButton!
    
    @IBOutlet weak var searchTaskTF: UITextField!
    
    @IBOutlet weak var taskTableView: UITableView!
    
    var lableSection: UILabel?
    
    var sectionLabels: [Int: UILabel] = [:]
    var contentSection = ["All"]
    let sectionMenus: [Int: [String]] = [
        0: ["Today", "Week", "Month","All"]
       ]
    
    var tasks: [NSManagedObject] =  [ ]
  
    var completedTasks: [NSManagedObject] = []
    var incompleteTasks: [NSManagedObject] = []
    
        override func viewDidLoad() {
        super.viewDidLoad()
            self.navigationController?.isNavigationBarHidden = true
        let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        
        taskTableView.register(nib, forCellReuseIdentifier: "TaskTableViewCell")
        
        taskTableView.showsVerticalScrollIndicator = false
        taskTableView.rowHeight = UITableView.automaticDimension
        setSearchButton()
        taskTableView.delegate = self
        taskTableView.dataSource = self
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleTaskUpdated(_:)), name: .taskUpdated, object: nil)
    }
    @objc func handleTaskUpdated(_ notification: Notification) {
        tasks = fetchTasks()
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
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        
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
        
        // Thiết lập placeholder với thuộc tính
        let placeholderText = "Search for your task..."
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray, // Màu của placeholder
            .font: UIFont.italicSystemFont(ofSize: searchTaskTF.font?.pointSize ?? 17) // Phông chữ của placeholder
        ]
        searchTaskTF.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
    }
    @objc func leftButtonTapped(){
        print("djfkjdf")
    }
    
    @IBAction func filterButton(_ sender: Any) {
        print("hello")
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        print("viewWillAppear")
        tasks =  fetchTasks()
        }
    
    @IBAction func profileNaviHandle(_ sender: Any) {
        print("profile")
    }
    
    
    
    //MARK: -fetchTasks
    func fetchTasks() -> [NSManagedObject] {
        // 1. Get the AppDelegate and the managed context
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2. Create a fetch request for the "Tasks" entity
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        // 3. Perform the fetch request and return the results
        do {
            let fetchedTasks = try managedContext.fetch(fetchRequest)
            return fetchedTasks
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }

   
    
    //MARK: -filterTask
    func filterTask(){
        completedTasks = tasks.filter { task in
                  if let status = task.value(forKey: "status") as? Bool {
                      return status
                  }
                  return false
              }
              
        incompleteTasks = tasks.filter { task in
                  if let status = task.value(forKey: "status") as? Bool {
                      return !status
                  }
                  return false
              }
        taskTableView.reloadData()
    }
    
    //MARK: -updateTaskStatus
    private func updateTaskStatus(_ task: NSManagedObject) {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
         let managedContext = appDelegate.persistentContainer.viewContext
         
         task.setValue(!(task.value(forKey: "status") as? Bool ?? false), forKey: "status")
         
         do {
             try managedContext.save()
             //fetchTasks() // Re-fetch tasks and reload the table view
         } catch let error as NSError {
             print("Could not save. \(error), \(error.userInfo)")
         }
     }
    
    //MARK: -deleteTask
    private func deleteTask(_ task: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext

        managedContext.delete(task)

        do {
            try managedContext.save()
            fetchTasks() // Re-fetch tasks and reload the table view
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    
    
    private func updateLabelInSection(_ title: String, forSection section: Int) {
        contentSection[section] = title
        if let label = sectionLabels[section] {
            label.text = title
        }
        
        let currentDate = Date()
        switch title {
        case "Today":
            tasks = filterTasksByToday(fetchTasks(), currentDate: currentDate)
            
        case "Week":
            tasks = filterTasksByWeek(fetchTasks(), currentDate: currentDate)
        case "Month":
            tasks = filterTasksByMonth(fetchTasks(), currentDate: currentDate)
        case "All":
             tasks = fetchTasks()
           
        default:
            tasks = [] // Clear tasks if title is unrecognized
        }
        taskTableView.reloadData()
        
    }

    // Filter tasks for today
    func filterTasksByToday(_ tasks: [NSManagedObject], currentDate: Date) -> [NSManagedObject] {
        return tasks.filter { task in
            guard let date = task.value(forKey: "date") as? Date else { return false }
            return isDateInToday(date, currentDate: currentDate)
            
        }
    }

    // Filter tasks for this week
    func filterTasksByWeek(_ tasks: [NSManagedObject], currentDate: Date) -> [NSManagedObject] {
        return tasks.filter { task in
            guard let date = task.value(forKey: "date") as? Date else { return false }
            return isDateInCurrentWeek(date, currentDate: currentDate)
        }
    }

    // Filter tasks for this month
    func filterTasksByMonth(_ tasks: [NSManagedObject], currentDate: Date) -> [NSManagedObject] {
        return tasks.filter { task in
            guard let date = task.value(forKey: "date") as? Date else { return false }
            return isDateInCurrentMonth(date, currentDate: currentDate)
        }
    }

    func isDateInToday(_ date: Date, currentDate: Date) -> Bool {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let taskComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return currentComponents.year == taskComponents.year &&
               currentComponents.month == taskComponents.month &&
               currentComponents.day == taskComponents.day
    }

//    func isDateInCurrentWeek(_ date: Date, currentDate: Date) -> Bool {
//        let calendar = Calendar.current
//        // Determine the start of the week (Sunday or Monday based on the calendar)
//        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
//        // End of the week is the current date
//        let endOfWeek = startOfWeek + 7
//        return date >= startOfWeek && date <= endOfWeek
//    }
    func isDateInCurrentWeek(_ date: Date, currentDate: Date) -> Bool {
        let calendar = Calendar.current
        // Determine the start of the week (Sunday or Monday based on the calendar setting)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        // End of the week is the current date
        let endOfWeek = currentDate
        return date >= startOfWeek && date <= endOfWeek
    }



    func isDateInCurrentMonth(_ date: Date, currentDate: Date) -> Bool {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let taskComponents = calendar.dateComponents([.year, .month], from: date)
        return currentComponents.year == taskComponents.year &&
               currentComponents.month == taskComponents.month
    }

    
}
extension HomeController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else{
            return UITableViewCell()
        }
        cell.contentView.layer.borderWidth = 0
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = .clear
        
        
        let task = tasks[indexPath.row]
            let title = task.value(forKey: "title") as? String
            let description = task.value(forKey: "descrip") as? String
            let selectPriorityforTask = task.value(forKey: "priority") as? String
            let status = task.value(forKey: "status") as? Bool
            let tag = task.value(forKey: "tag") as? String //catename
            let color = task.value(forKey: "colorCate") as? String
        
            let date = task.value(forKey: "date") as? Date
        
            let imagecate = task.value(forKey: "imagecate") as? String
            
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
        
            cell.buttonAction = { [weak self] in
                guard let self = self else { return }
                self.updateTaskStatus(task)
            }
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

    
    //MARK: -showContextMenu
    @objc func showContextMenu(_ sender: UIButton) {
        let section = sender.tag
        guard let menuItems = sectionMenus[section] else { return }

        let actions = menuItems.map { item in
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
         let newPostVC = storyboard?.instantiateViewController(withIdentifier: "EditTaskViewController") as? EditTaskViewController
        let navigation = UINavigationController(rootViewController: newPostVC ?? UINavigationController())
        navigation.modalPresentationStyle = .fullScreen
                present(navigation, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}




        
