//
//  CalendarViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    @IBOutlet weak var monthLable: UILabel!
    @IBOutlet weak var yearLable: UILabel!
    @IBOutlet weak var changeTitleLableButton: UIButton!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calendarPickerView: UIPickerView!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    
    var dateService = DateService()
    var selectDateMode: Bool = false
    var selectedDate: Date?
    var daysAndWeekdaysInMonth: [(day: Int, weekday: String)] = []
    var homeViewModel  =  HomeViewModel()
    var choose = false
    var headerView = HeaderViewForCalendar()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change the title color of the navigation bar
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString:"FFFFFF", alpha: 0.87) ?? UIColor()]
        title = "Calendar"
        // Set up the layout with horizontal scrolling
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 53, height: 80) // Adjust the item size as needed
        layout.scrollDirection = .horizontal // Set the scroll direction to horizontal
        calendarCollectionView.collectionViewLayout = layout
        
        let nibCalendar = UINib(nibName: "CalendarOfDayCollectionViewCell", bundle: nil)
        calendarCollectionView.register(nibCalendar, forCellWithReuseIdentifier: "CalendarOfDayCollectionViewCell")
        calendarCollectionView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
       // calendarCollectionView.showsVerticalScrollIndicator = false

        changeTitleLableButton.addTarget(self, action: #selector(chooseMonthAndYearButton_TUI), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousMonthButton_TUI), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonthButton_TUI), for: .touchUpInside)
        
        
        daysAndWeekdaysInMonth = dateService.getDaysAndWeekdaysInMonth(month: dateService.monthTitleText , year: Int(dateService.yearTitleText) ?? Int())
        refreshTitle()
        refreshButtons()
        print( dateService.monthTitleText)
    
        calendarCollectionView.reloadData()
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskTableViewCell")
        
   
    }
    override func viewWillAppear(_ animated: Bool) {
        print(viewWillAppear)
//        homeViewModel.tasks = homeViewModel.fetchTasks() ?? [NSManagedObject()]
//        tableView.reloadData()
        
        let currentDate = Date()
        let filteredDate = selectedDate ?? currentDate

        print(homeViewModel.fetchTasks())
        
        homeViewModel.tasks = homeViewModel.fetchTasks().filter({ task in
            guard let dateofTask = task.date as? Date else {
                return false
            }
            // Compare the dates for equality
            return dateofTask.isEqual(filteredDate)
        })
        tableView.reloadData()
    }
    
    func reloadValues() {
        refreshTitle()
        refreshButtons()
        print(dateService.monthTitleText)
        daysAndWeekdaysInMonth = dateService.getDaysAndWeekdaysInMonth(month: dateService.monthTitleText , year: Int(dateService.yearTitleText) ?? Int())
        calendarCollectionView.reloadData()
    }
    
    func refreshTitle() {
        monthLable.text = dateService.monthTitleText
        yearLable.text = dateService.yearTitleText
    }

    
    func refreshButtons() {
        previousButton.isHidden = dateService.isInMinDate()
        nextButton.isHidden = dateService.isInMaxDate()
    }
    
    func checkSelectedDate() {
        if selectedDate?.isBefore(dateService.minDate) == true || selectedDate?.isAfter(dateService.maxDate) == true {
            selectedDate = nil
            
        }
    }
    @objc func previousMonthButton_TUI(){
        dateService.goLastMonth()
        reloadValues()
    }
    
    @objc func nextMonthButton_TUI(){
        dateService.goNextMonth()
        reloadValues()
    }
    @objc func chooseMonthAndYearButton_TUI() {
        //view.bringSubviewToFront(calendarPickerView)
        refreshTitle()
        selectDateMode = !selectDateMode
        if selectDateMode {
            if let monthIndex = dateService.monthsForPicker.firstIndex(of: dateService.date.monthName()) {
                calendarPickerView.selectRow(monthIndex, inComponent: 0, animated: false)
            }
            if let yearIndex = dateService.yearsForPicker.firstIndex(of: String(dateService.date.year())) {
                calendarPickerView.selectRow(yearIndex, inComponent: 1, animated: false)
            }
        }
        calendarCollectionView.isHidden = selectDateMode
        previousButton.isHidden = selectDateMode
        nextButton.isHidden = selectDateMode
        calendarPickerView.isHidden = !selectDateMode
        if !selectDateMode { reloadValues() }
    }
    
    
    
}
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysAndWeekdaysInMonth.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let calendarDate = dateService.getCalendarDate(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarOfDayCollectionViewCell", for: indexPath) as! CalendarOfDayCollectionViewCell
                let dayAndWeekday = daysAndWeekdaysInMonth[indexPath.item]
                cell.dayNumberLabel.text = String(dayAndWeekday.day)
        cell.weekdayLable.text = dayAndWeekday.weekday.prefix(3).uppercased()
            print("\(dayAndWeekday.day)\n\(dayAndWeekday.weekday)")
        cell.setup(calendarDate, selected: calendarDate.date.isEqual(selectedDate))
                return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        guard let selectedDate = dateService.daySelected1(indexPath) else { return }
        self.selectedDate = selectedDate
        
        print("Selected date: \(selectedDate.toString())")
       // calendarPickerView.setDate(selectedDate, animated: true)
        let currentDate = Date()
        let filteredDate = selectedDate ?? currentDate

        homeViewModel.tasks = homeViewModel.fetchTasks().filter({ task in
            guard let dateofTask = task.date as? Date else {
                return false
            }
            // Compare the dates for equality
            return dateofTask.isEqual(filteredDate)
        })
        tableView.reloadData()
        reloadValues()
    }
}
extension CalendarViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? dateService.monthsForPicker.count : dateService.yearsForPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return dateService.monthsForPicker[row] }
        return dateService.yearsForPicker[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateService.pickerValueChanged(row, component)
        refreshTitle()
        pickerView.reloadAllComponents()
        daysAndWeekdaysInMonth = dateService.getDaysAndWeekdaysInMonth(month: dateService.monthTitleText , year: Int(dateService.yearTitleText) ?? Int())
        calendarCollectionView.reloadData()
    }
}
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else{
            return UITableViewCell()
        }
        cell.selectionStyle = . none
        
        let task = homeViewModel.tasks[indexPath.row]

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = homeViewModel.tasks[indexPath.row]
         let newEditVC = storyboard?.instantiateViewController(withIdentifier: "EditTaskViewController") as? EditTaskViewController
        newEditVC?.task = task
        newEditVC?.indexPathRow =  indexPath.row
        print(task)
        
        
        
        newEditVC?.taskClosure = { taskCompletion in
            print(taskCompletion)
            self.homeViewModel.updateTask(taskCompletion)

            tableView.reloadData()
        }
        
        
        let navigation = UINavigationController(rootViewController: newEditVC ?? UINavigationController())
        navigation.modalPresentationStyle = .fullScreen
                present(navigation, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in

                let task = self.homeViewModel.tasks[indexPath.row]
                print(task)
                print(self.homeViewModel.tasks)
                self.homeViewModel.tasks.remove(at: indexPath.row)
                print(self.homeViewModel.tasks)
                tableView.reloadData()
                self.homeViewModel.deleteTask(task)
                
             print(self.homeViewModel.fetchTasks())
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         
        headerView.contentView.layer.cornerRadius = 4
        headerView.contentView.layer.masksToBounds = true
        
                headerView.todayButton.layer.borderWidth = 2
        headerView.todayButton.layer.cornerRadius = 4
        headerView.todayButton.layer.masksToBounds = true
                headerView.todayButton.layer.borderColor  = UIColor(hexString: "979797")?.cgColor
        
        headerView.completedButton.layer.borderWidth = 2
        headerView.completedButton.layer.cornerRadius = 4
        headerView.completedButton.layer.masksToBounds = true
        headerView.completedButton.layer.borderColor  = UIColor(hexString: "979797")?.cgColor
       
        
        //event
        headerView.todayButton.addTarget(self, action: #selector(todayTask), for: .touchUpInside)
        headerView.completedButton.addTarget(self, action: #selector(completedofTodayTask), for: .touchUpInside)
        return headerView
    }
   
    @objc func todayTask(){
 
            headerView.todayButton.layer.borderWidth = 0
            headerView.todayButton.layer.cornerRadius = 4
            headerView.todayButton.layer.masksToBounds = true
            headerView.todayButton.layer.borderColor  = UIColor(hexString: "8687E7")?.cgColor
            headerView.todayButton.backgroundColor = UIColor(hexString: "8687E7")
//            UIColor(hexString: "8687E7")?.cgColor
        
        
            headerView.completedButton.layer.borderWidth = 2
            headerView.completedButton.layer.cornerRadius = 4
            headerView.completedButton.layer.masksToBounds = true
            headerView.completedButton.layer.borderColor  = UIColor(hexString: "979797")?.cgColor
            headerView.completedButton.backgroundColor = .clear
        
        
        let currentDate = Date()
        let filteredDate = selectedDate ?? currentDate

        homeViewModel.tasks = homeViewModel.fetchTasks().filter({ task in
            guard let dateofTask = task.date as? Date else {
                return false
            }
            // Compare the dates for equality
            return dateofTask.isEqual(filteredDate)
        })
        tableView.reloadData()
    }
    
    @objc func completedofTodayTask (){
        print("completedofTodayTask")
        headerView.completedButton.layer.borderWidth = 0
        headerView.completedButton.layer.cornerRadius = 4
        headerView.completedButton.layer.masksToBounds = true
        headerView.completedButton.layer.borderColor  = UIColor(hexString: "8687E7")?.cgColor
        headerView.completedButton.backgroundColor = UIColor(hexString: "8687E7")
//            UIColor(hexString: "8687E7")?.cgColor
    
    
        headerView.todayButton.layer.borderWidth = 2
        headerView.todayButton.layer.cornerRadius = 4
        headerView.todayButton.layer.masksToBounds = true
        headerView.todayButton.layer.borderColor  = UIColor(hexString: "979797")?.cgColor
        headerView.todayButton.backgroundColor = .clear

        let currentDate = Date()
        let filteredDate = selectedDate ?? currentDate

        homeViewModel.tasks = homeViewModel.fetchTasks().filter({ task in
            guard let dateofTask = task.date as? Date else {
                return false
            }
            // Compare the dates for equality
            return dateofTask.isEqual(filteredDate)
        }).filter({ task in
            guard let status = task.date as? Bool else{
                return false
            }
            return status == true
        })
        print(homeViewModel.tasks)
        
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}
