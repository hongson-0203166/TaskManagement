//
//  EditTaskViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 30/05/2024.
//

import UIKit
import CoreData
class EditTaskViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editPrimaryTaskButton: UIButton!
    @IBOutlet weak var deleteTaskView: DeleteTaskView!
    @IBOutlet weak var editTitleTaskView: EditTaskTitleView!
    @IBOutlet weak var editCategoryView: EditCategoryView!
    @IBOutlet weak var editPriorityView: EditPriorityView!
    @IBOutlet weak var editCarlendarView: EditCalenderView!
    @IBOutlet weak var editTimeView: EditTimeView!
    
    var imageForEditTask = ["timer","tag","flag","trash"]
    var lableForEditTask = ["Task Time :", "Task Category :", "Task Priority :", "Delete Task"]
    var categoryForButtonImage = ["fgfgf","timer","flag","vffgf"]
    var contentEditTask = ["Today At 16:45", "University", "Default", "Add Sub - Task"]
    
    //category
    var categoryName =  ["Grocery", "Work", "Sport", "Design", "University", "Social", "Music", "Health", "Movie", "Home 1", "Create New"]
    var categoryImage = ["Grocery","Work","Sport","Design","University","Social","Music","Health","Movie","Home 1","Create New"]
    var categoryColor = ["CCFF80", "FF9680", "80FFFF", "80FFD9", "809CFF", "FF80EB", "FC80FF", "80FFA3", "80D1FF", "FFCC80", "80FFD1"]
    
    var dateService = DateService()
    var selectDateMode: Bool = false
    var selectTimerforTask: Date?
    
    var task: Task?
    var indexPathRow: Int?
    var headerView: EditTaskHeaderView?
    var blurEffectView: UIVisualEffectView?
    var selectedDate: Date?
    var previousSelectedIndexPath: IndexPath?
    
    
    var doOrDoneTask:Bool?
    var titleTask:String?
    var descriptionTask:String?
    var dateofTimeTask:Date?
    var categoryTask:String?
    var categoryImageTask: String?
    var priorityTask:String?
    var categoryColorTask:String?
    
    //nil
    var nildoOrDoneTask:Bool = false
    var niltitleTask:String?
    var nildescriptionTask:String?
    var nildateofTimeTask:Date?
    var nilcategoryTask:String?
    var nilcategoryImageTask: String?
    var nilpriorityTask:String?
    var nilcategoryColorTask:String?
    
    
    var viewmodel = HomeViewModel()
    var taskClosure: ((Task) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.isScrollEnabled = false
        tableView.register(UINib(nibName: "EditTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "EditTaskTableViewCell")
        editPrimaryTaskButton.layer.cornerRadius = 4
        editPrimaryTaskButton.layer.masksToBounds = true
        
        
        let date = task?.date as? Date
        nildateofTimeTask = date
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let formattedTime = formatter.string(from: date ?? Date())
        let selectPriorityforTask = task?.priority as? String
        nilpriorityTask = selectPriorityforTask
        let tag = task?.tag as? String
        nilcategoryTask = tag
        contentEditTask = ["Today At \(formattedTime)", tag ?? "", selectPriorityforTask ?? "", "" ]
        
        
        let color = task?.colorCate as? String
        nilcategoryColorTask = color
        let imagecate = task?.imagecate as? String
        nilcategoryImageTask = imagecate
        categoryForButtonImage = ["jkhkj",imagecate ?? "","flag","kjlk"]
        tableView.reloadData()
        
        customizeSubView()
        
        // Create the blur effect view
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
               blurEffectView = UIVisualEffectView(effect: blurEffect)
               blurEffectView?.frame = self.view.bounds
               blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               
               // Initially hide the blur effect view
               blurEffectView?.isHidden = true
               self.view.addSubview(blurEffectView!)
        
        
        editPrimaryTaskButton.addTarget(self, action: #selector(acceptEditOfTask), for: .touchUpInside)
    }
    
    @objc func acceptEditOfTask(){
   
        if doOrDoneTask != nil && titleTask != nil && descriptionTask != nil && categoryTask != nil && categoryColorTask != nil && priorityTask != nil && dateofTimeTask != nil {
            dissmiss()
            return
        }
        

        task?.title = titleTask ?? niltitleTask!
        task?.descrip = descriptionTask ?? nildescriptionTask!
        task?.priority = priorityTask ?? nilpriorityTask!
        task?.status = doOrDoneTask ?? nildoOrDoneTask
        task?.tag = categoryTask ?? nilcategoryTask!
        task?.colorCate = categoryColorTask ?? nilcategoryColorTask!
        task?.date = dateofTimeTask ?? nildateofTimeTask!
        task?.imagecate = categoryImageTask ?? nilcategoryImageTask!
        
//        task?.setValue(titleTask ?? niltitleTask, forKey: "title")
//        task?.setValue(descriptionTask ?? nildescriptionTask, forKey: "descrip")
//        task?.setValue(priorityTask ?? nilpriorityTask, forKey: "priority")
//        task?.setValue(doOrDoneTask ?? nildoOrDoneTask, forKey: "status")
//        task?.setValue(categoryTask ?? nilcategoryTask, forKey: "tag")
//        task?.setValue(categoryColorTask ?? nilcategoryColorTask, forKey: "colorCate")
//        task?.setValue(dateofTimeTask ?? nildateofTimeTask, forKey: "date")
//        task?.setValue(categoryImageTask ?? nilcategoryImageTask, forKey: "imagecate")
        taskClosure?(task ?? Task(id: "", colorCate: "", date: Date(), descrip: "", imagecate: "", lastUpdated: Date(), priority: "", status: false, tag: "", title: "", isdeleted: false))
           dissmiss()
        print("update")
      
    }
    
    func customizeSubView(){
        deleteTaskView.layer.cornerRadius = 4
        deleteTaskView.layer.masksToBounds = true
        deleteTaskView.cancelDeleteButton.addTarget(self, action: #selector(cancelClearSubView), for: .touchUpInside)
        deleteTaskView.accecptDeleteButton.layer.cornerRadius = 4
        deleteTaskView.accecptDeleteButton.layer.masksToBounds = true
        
        
        editTitleTaskView.layer.cornerRadius = 4
        editTitleTaskView.layer.masksToBounds = true
        editTitleTaskView.editTitleButton.layer.cornerRadius = 4
        editTitleTaskView.editTitleButton.layer.masksToBounds = true
        editTitleTaskView.cancelEditTitleButton.addTarget(self, action: #selector(cancelClearSubView), for: .touchUpInside)
        deleteTaskView.accecptDeleteButton.addTarget(self, action: #selector(acceptDeleteTask), for: .touchUpInside)

        
        // Customize the title text field
        
        editTitleTaskView.editTitleTextField.setLeftPaddingPoints(8)
        editTitleTaskView.editTitleTextField.setBorder(color: UIColor(hexString: "979797") ?? .white, width: 1.0)
        editTitleTaskView.editTitleTextField.layer.cornerRadius = 4
        editTitleTaskView.editTitleTextField.layer.masksToBounds = true
        editTitleTaskView.editTitleTextField.borderStyle = .roundedRect
        editTitleTaskView.editTitleTextField.keyboardAppearance = .dark

        
        // Customize the description text field
        
        editTitleTaskView.editDescriptionTextField.setLeftPaddingPoints(8)
        editTitleTaskView.editDescriptionTextField.setBorder(color: UIColor(hexString: "979797") ?? .white, width: 1.0)
        editTitleTaskView.editDescriptionTextField.layer.cornerRadius = 4
        editTitleTaskView.editDescriptionTextField.layer.masksToBounds = true
        editTitleTaskView.editDescriptionTextField.borderStyle = .roundedRect
        editTitleTaskView.editDescriptionTextField.keyboardAppearance = .dark
        guard let description = task?.descrip as? String else { return  }
        guard let title = task?.title as? String else { return  }
        
        editTitleTaskView.editDescriptionTextField.setPlaceholder(description, withColor: UIColor(hexString: "979797") ?? .white)
        editTitleTaskView.editTitleTextField.setPlaceholder(title, withColor: UIColor(hexString: "979797") ?? .white)
        editTitleTaskView.editTitleButton.addTarget(self, action: #selector(acceptTitleAndDes), for: .touchUpInside)
        
        
        //edit CategoryView
        editCategoryView.editCategoryCollectionView.setup("CategoryCollectionViewCell", CategoryViewFlowLayout())
        editCategoryView.editCategoryCollectionView.delegate = self
        editCategoryView.editCategoryCollectionView.dataSource = self
        editCategoryView.addCategoryButton.addTarget(self, action: #selector(editSaveCategory), for: .touchUpInside)
        
        
        //edit Priority
        editPriorityView.editTaskPriorityCollectionView.setup("PriorityCollectionViewCell", PriorityCollectionViewFlowLayout())
        editPriorityView.editTaskPriorityCollectionView.delegate = self
        editPriorityView.editTaskPriorityCollectionView.dataSource = self
        editPriorityView.cancelTaskPriorityButton.addTarget(self, action: #selector(cancelClearSubView), for: .touchUpInside)
        editPriorityView.editTaskPriorityButton.addTarget(self, action: #selector(editTaskPriority), for: .touchUpInside)
        
//        //edit Calendar
//
        
        editCarlendarView.calendarCV.setup("CalendarDayCVC", CalendarDayFlowLayout())
        editCarlendarView.calendarCV.dataSource = self
        editCarlendarView.calendarCV.delegate = self
        
        
        editCarlendarView.datePickerView.dataSource = self
        editCarlendarView.datePickerView.delegate = self
        editCarlendarView.previousMonthButton.addTarget(self, action: #selector(previousMonthButton_TUI), for: .touchUpInside)
        
        editCarlendarView.nextMonthButton.addTarget(self, action: #selector(nextMonthButton_TUI), for: .touchUpInside)
        editCarlendarView.monthAndYearButton.addTarget(self, action: #selector(chooseMonthAndYearButton_TUI), for: .touchUpInside)
        editCarlendarView.cancelEditTimeButton.addTarget(self, action: #selector(cancelClearSubView), for: .touchUpInside)
        editCarlendarView.chooseTimeButton.addTarget(self, action: #selector(chooseTimeOfDate), for: .touchUpInside)
        
        editTimeView.cancelChooseTime.addTarget(self, action: #selector(cancelChooseTime), for: .touchUpInside)
        editTimeView.editChooseTime.addTarget(self, action: #selector(editChooseTimeofDate), for: .touchUpInside)
        
        
    
        refreshTitle()
        refreshButtons()
    }
    
    
    @objc func acceptTitleAndDes(){
        
        
        if ((titleTask?.isEmpty) == nil) || ((descriptionTask?.isEmpty) == nil){
            print("Fill format text in textField")
            titleTask = editTitleTaskView.editTitleTextField.placeholder
            descriptionTask = editTitleTaskView.editDescriptionTextField.placeholder
           
        }else{
           
            titleTask =  editTitleTaskView.editTitleTextField.text
            descriptionTask = editTitleTaskView.editDescriptionTextField.text
        }
        headerView?.titleTaskLable.text = titleTask ?? ""
        headerView?.descriptionTaskLable.text = descriptionTask ?? ""
        
        print("titleTask: \(titleTask)")
        print("descriptionTask: \(descriptionTask)")
        cancelClearSubView()
    }
    
    
    //deleteTask
    @objc func acceptDeleteTask(){
        print(task)
        viewmodel.tasks.remove(at: indexPathRow ?? Int())
        viewmodel.deleteTask(task ?? Task(id: "", colorCate: "", date: Date(), descrip: "", imagecate: "", lastUpdated: Date(), priority: "", status: false, tag: "", title: "", isdeleted: false))
        dissmiss()
        cancelClearSubView()
    }
    
    //get timeofdate
    @objc func editChooseTimeofDate(){
        let date = editTimeView.timeOfDatePiker.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let formattedTime = formatter.string(from: date ?? Date())
        print(formattedTime)
        contentEditTask = ["Today At \(formattedTime)", "University", "Default", "Add Sub - Task"]
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
      
        dateofTimeTask = date
        print("dateofTimeTask: \(dateofTimeTask)")
        //tableView.reloadData()
        cancelClearSubView()
        
    }
    
    //get priority
    @objc func editTaskPriority(){
        print("priorityTask \(priorityTask)")
        
        cancelClearSubView()
    }
    
    
//    get priority
    @objc func editSaveCategory(){
        print("categoryTask: \(categoryTask)")
        print("categoryColorTask: \(categoryColorTask)")
        editCategoryView.isHidden = true
        blurEffectView?.isHidden = true
    }
    @objc func cancelChooseTime(){
        editTimeView.isHidden = true
        editCarlendarView.isHidden = false
        view.bringSubviewToFront(editCarlendarView)
    }
    
    @objc func chooseTimeOfDate(){
        editCarlendarView.isHidden = true
        editTimeView.isHidden = false
        view.bringSubviewToFront(editTimeView)
    }
    @objc func cancelClearSubView(){
        editTitleTaskView.isHidden = true
        editPriorityView.isHidden = true
       deleteTaskView.isHidden = true
        editCarlendarView.isHidden = true
        blurEffectView?.isHidden = true
        editTimeView.isHidden = true
    }
    
  
    @objc func backButtonTapped(){
        self.dismiss(animated: true)
    }
  
    
}
extension EditTaskViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lableForEditTask.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTaskTableViewCell") as? EditTaskTableViewCell else{
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        cell.configureUIforCell(iconOfTask: imageForEditTask[indexPath.row], lableOfEditTask: lableForEditTask[indexPath.row], cateGoryLable: contentEditTask[indexPath.row], categoryIcoYImage: categoryForButtonImage[indexPath.row])
        
        let description = task?.descrip as? String
        
        let title = task?.title as? String
        niltitleTask = title
        nildescriptionTask = description
        
        
        if indexPath.row == lableForEditTask.count - 1 {
            cell.viewforButtonTask.isHidden = true
            cell.lableofEditTask.textColor = UIColor(hexString: "FF4949")
            } else {
                cell.viewforButtonTask.isHidden = false
                cell.lableofEditTask.textColor = UIColor(hexString: "FFFFFF", alpha: 0.87)
            }
        
        cell.completion = { [weak self] in
            print("edit \(indexPath.row)")
            if indexPath.row == 1{
                self?.editCategoryView.isHidden = false
                self?.blurEffectView?.isHidden = false
                self?.blurEffectView?.alpha = 0.75
                self?.view.bringSubviewToFront(self!.editCategoryView)
                
            }else if indexPath.row == 2{
                self?.editPriorityView.isHidden = false
                self?.blurEffectView?.isHidden = false
                self?.blurEffectView?.alpha = 0.75
                self?.view.bringSubviewToFront(self!.editPriorityView)
            }else{
                self?.editCarlendarView.isHidden = false
                self?.blurEffectView?.isHidden = false
                self?.blurEffectView?.alpha = 0.75
                self?.view.bringSubviewToFront(self!.editCarlendarView)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == lableForEditTask.count - 1 {
            deleteTaskView.isHidden = false
            blurEffectView?.isHidden = false
            view.bringSubviewToFront(deleteTaskView)
            blurEffectView?.alpha = 0.75
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         headerView = EditTaskHeaderView()
        headerView?.backgroundColor = UIColor(hexString: "121212")
        
        headerView?.editTitleAndDesButton.addTarget(self, action: #selector(editTitleAndDes), for: .touchUpInside)
        headerView?.dissmissButton.addTarget(self, action: #selector(dissmiss), for: .touchUpInside)
        headerView?.editReloadButton.addTarget(self, action: #selector(editReload), for: .touchUpInside)
        headerView?.todoOrDoneButton.addTarget(self, action: #selector(doAndDone), for: .touchUpInside)
        
        
        headerView?.titleTaskLable.text = task?.title as? String
        headerView?.descriptionTaskLable.text = task?.descrip as? String
        
        
        let status = task?.status as? Bool
            // Set the button image based on the status
        let buttonImageName = (status ?? false) ? "circle 1" : "circle"
        headerView?.todoOrDoneButton.setImage(UIImage(named: buttonImageName), for: .normal)
        
        return headerView
    }
  
    @objc func editTitleAndDes(){
        editTitleTaskView.isHidden = false
        editTitleTaskView.editTitleTextField.becomeFirstResponder()
        view.bringSubviewToFront(editTitleTaskView)
        blurEffectView?.isHidden = false
        blurEffectView?.alpha = 0.75
    }
    @objc func dissmiss(){
        self.dismiss(animated: true)
    }
    
    @objc func editReload(_sender: Any){
        let date = task?.date as? Date
      //  nildateofTimeTask = date
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let formattedTime = formatter.string(from: date ?? Date())
        let selectPriorityforTask = task?.priority as? String
        let tag = task?.tag as? String
        contentEditTask = ["Today At \(formattedTime)", tag ?? "", selectPriorityforTask ?? "", "" ]
        
        
        let color = task?.colorCate as? String
        nilcategoryColorTask = color
        let imagecate = task?.imagecate as? String
        nilcategoryImageTask = imagecate
        categoryForButtonImage = ["dfdf",imagecate ?? "", "flag","dfdfd"]
        tableView.reloadData()
        
        // Reset the button image to its initial state
           let status = task?.status as? Bool ?? false
        nildoOrDoneTask = status
           let buttonImageName = status ? "circle 1" : "circle"
        headerView?.todoOrDoneButton.setImage(UIImage(named: buttonImageName), for: .normal)
           
        // Reset the title and description labels
        headerView?.titleTaskLable.text = task?.title as? String
        headerView?.descriptionTaskLable.text = task?.descrip as? String
        
        print("editReload")
    }
    
    @objc func doAndDone(_ sender: UIButton) {
        // Check if the current button image is "circle 1"
        let isCircle1Image = sender.currentImage == UIImage(named: "circle 1")
        
        // Set the status based on the current image
        let status = isCircle1Image
        
        // Update the button image based on the status
        let buttonImageName = status ? "circle" : "circle 1"
        sender.setImage(UIImage(named: buttonImageName), for: .normal)
        doOrDoneTask = !status
        print("doOrDoneTask: \(doOrDoneTask)")
        //print(!status)
    }

    func reloadValues() {
        refreshTitle()
        refreshButtons()
            editCarlendarView.calendarCV.reloadData()
    }
    func refreshTitle() {
        
        editCarlendarView.monthTitleLable.text = dateService.monthTitleText
        editCarlendarView.yearTitleLable.text = dateService.yearTitleText
    }
    func refreshButtons() {
        editCarlendarView.previousMonthButton.isHidden = dateService.isInMinDate()
        editCarlendarView.nextMonthButton.isHidden = dateService.isInMaxDate()
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
    
    @objc func chooseMonthAndYearButton_TUI(){
        refreshTitle()
        selectDateMode = !selectDateMode
        if selectDateMode {
            if let monthIndex = dateService.monthsForPicker.firstIndex(of: dateService.date.monthName()) {
                editCarlendarView.datePickerView.selectRow(monthIndex, inComponent: 0, animated: false)
            }
            if let yearIndex = dateService.yearsForPicker.firstIndex(of: String(dateService.date.year())) {
                editCarlendarView.datePickerView.selectRow(yearIndex, inComponent: 1, animated: false)
            }
        }
            editCarlendarView.calendarCV.isHidden = selectDateMode
            editCarlendarView.previousMonthButton.isHidden = selectDateMode
        editCarlendarView.nextMonthButton.isHidden = selectDateMode
        editCarlendarView.daysStackView.isHidden = selectDateMode
        editCarlendarView.datePickerView.isHidden = !selectDateMode
        if !selectDateMode { reloadValues() }
    }
}

extension EditTaskViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
        switch collectionView{
        case editPriorityView.editTaskPriorityCollectionView:
            return 1
        case editCarlendarView.calendarCV:
            return dateService.numberOfSections
        case editCategoryView.editCategoryCollectionView:
            return 1
        default:
            break
        }
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categoryName.count
        switch collectionView{
        case editPriorityView.editTaskPriorityCollectionView:
            return 10
        case editCarlendarView.calendarCV:
            return 7
        case editCategoryView.editCategoryCollectionView:
            return categoryName.count
        default:
            break
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarDate = dateService.getCalendarDate(indexPath)
        switch collectionView{
        case editPriorityView.editTaskPriorityCollectionView:
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "PriorityCollectionViewCell", for: indexPath) as! PriorityCollectionViewCell
            cell1.setup(indexPath: indexPath)
            return cell1
        case editCarlendarView.calendarCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCVC", for: indexPath) as! CalendarDayCVC
            cell.setup(calendarDate, selected: calendarDate.date.isEqual(selectedDate))
            return cell
            
        case editCategoryView.editCategoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.setupUI(nameCategory: categoryName[indexPath.row], categoryImage: categoryImage[indexPath.row], categoryColor: categoryColor[indexPath.row])
            return cell
        default:
            break
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView{
            
        case editPriorityView.editTaskPriorityCollectionView:
            if let cell = collectionView.cellForItem(at: indexPath) as? PriorityCollectionViewCell {
                cell.priorityView.backgroundColor = UIColor(hexString: "8687E7")
                let selectedFlag = indexPath.row + 1
                        
              
                priorityTask = "\(selectedFlag)"
                print("priorityTask: \(priorityTask)")
                
                contentEditTask = ["Today At ", "University","\(selectedFlag)" , "Add Sub - Task"]
                tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                
             
            }
            
            // Nếu có cell được chọn trước đó, thì cập nhật lại màu sắc của cell đó
            if let previousSelectedIndexPath = previousSelectedIndexPath {
                if let previousSelectedCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? PriorityCollectionViewCell {
                    // Đặt màu sắc của cell trở lại màu gốc
                    previousSelectedCell.priorityView.backgroundColor = UIColor(hexString: "272727")
                }
            }
            
            // Lưu indexPath của cell được chọn hiện tại làm indexPath của cell đã được chọn trước đó
            previousSelectedIndexPath = indexPath
            
        
            
        case editCarlendarView.calendarCV:
            print("\(indexPath.row)")
            guard let selectedDate = dateService.daySelected(indexPath) else { return }
            self.selectedDate = selectedDate
            
            print("Selected date: \(selectedDate.toString())")
            editTimeView.timeOfDatePiker.setDate(selectedDate, animated: true)
            reloadValues()
            
            
        case editCategoryView.editCategoryCollectionView:
            let totalItems = collectionView.numberOfItems(inSection: indexPath.section)
               print(totalItems)
                
               if indexPath.row == totalItems - 1 {
                   if totalItems == 18 {
//                       showAlertError(message: "Need to delete item if you wana add")
                       return
                   }
                   let newCategoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewCategoryViewController") as! CreateNewCategoryViewController
                   
                   newCategoryVC.completion = {  (cateName: String, cateIcon: String, cateColor: String) in
                       print(cateName)
                       print(cateIcon)
                       print(cateColor)
                       self.categoryName.insert(cateName, at: 10)
                       self.categoryImage.insert(cateIcon, at: 10)
                       self.categoryColor.insert(cateColor, at: 10)
                       collectionView.reloadData()
                   }
                   
                   newCategoryVC.modalPresentationStyle = .fullScreen
                   present(newCategoryVC, animated: true)
                   
               }
            
                print(indexPath.row)
                print("categoryName: " + categoryName[indexPath.row])
                print("categoryImage: " + categoryImage[indexPath.row])
                print("categoryColor: " + categoryColor[indexPath.row])
                
            categoryTask = categoryName[indexPath.row]
            categoryImageTask = categoryImage[indexPath.row]
            print("categoryTask: \(categoryTask)")
            categoryColorTask = categoryColor[indexPath.row]
            
            
            contentEditTask = ["Today At ", "\(categoryTask ?? "")","" , "Add Sub - Task"]
            categoryForButtonImage = ["đfdff","\(categoryImageTask ?? "")","flag","đfff"]
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        default:
            break
        }
    }
    
    
    
}
extension EditTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource{
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
            editCarlendarView.datePickerView.reloadAllComponents()
    }
    
}
