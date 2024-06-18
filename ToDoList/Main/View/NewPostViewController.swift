//
//  NewPostViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 08/05/2024.
//

import UIKit
import SnapKit
import SwiftHEXColors
import CoreData

protocol BlurVCDelegate: class {
    func removeBlurView()
}

class NewPostViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tapView: UIView!
   
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak private var monthAndYearButton: UIButton!
    
    @IBOutlet weak var daysStackView: UIStackView!
    @IBOutlet weak private var calendarCV: UICollectionView!
    @IBOutlet weak var datePickerView: UIPickerView!
    
    @IBOutlet weak var monthTitleLable: UILabel!
    @IBOutlet weak var yearTitleLable: UILabel!
    @IBOutlet weak var chooseTimeButton: UIButton!
    
    @IBOutlet weak var timePickerView: UIDatePicker!
    
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var inventoryView: UIView!
    @IBOutlet weak var titleCalendarView: UIView!
    
    @IBOutlet weak var chooseTimeView: UIView!
    
    @IBOutlet weak var taskPriorityView: UIView!
    
    
    @IBOutlet weak var taskCollectionView: UICollectionView!
    
    //setBorder
    
    @IBOutlet weak var hourView: UIView!
    
    @IBOutlet weak var minuteView: UIView!
    @IBOutlet weak var halfDayView: UIView!
    
    @IBOutlet weak var saveTimeButton: UIButton!
    
    
    @IBOutlet weak var cancelTaskPriority: UIButton!
    
    @IBOutlet weak var saveTaskPriority: UIButton!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var addCategory: UIButton!
    
    
        
    // MARK: - Variables
    
    var dateService = DateService()
    var selectDateMode: Bool = false
    var selectTimerforTask: Date?
    var selectCategoryforTask: String?
    var selectCategoryImageNameforTask: String?
    var selectCategoryColorforTask:String?
    var selectPriorityforTask: String?
    
    var tasks: [NSManagedObject] = []

    var selectedDate: Date?
    var categoryName =  ["Grocery", "Work", "Sport", "Design", "University", "Social", "Music", "Health", "Movie", "Home 1", "Create New"]
    var categoryImage = ["Grocery","Work","Sport","Design","University","Social","Music","Health","Movie","Home 1","Create New"]
    
    
    
    var categoryColor = ["CCFF80", "FF9680", "80FFFF", "80FFD9", "809CFF", "FF80EB", "FC80FF", "80FFA3", "80D1FF", "FFCC80", "80FFD1"]
    weak var delegatee: BlurVCDelegate?
    
    var previousSelectedIndexPath: IndexPath?
    
    //MARK: - UI Constraint layout
    
    var accessoryView : UIView = {
        let view = UIView()
        view.backgroundColor =   UIColor(hexString: "363636")
        // Thiết lập bo tròn góc chỉ ở hai đỉnh
        let cornerRadius: CGFloat = 16 // Bán kính bo tròn
        let maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Bo tròn góc ở đỉnh trên phải và đỉnh dưới trái

        // Thiết lập bo tròn góc và masked corners
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = maskedCorners
        return view
    }()
    
    var addTaskLable:UILabel = {
        let lable = UILabel()
        lable.text = "Add Task"
        lable.textColor = .white
        lable.font = .systemFont(ofSize: 20, weight: .bold)
        return lable
    }()
    
    var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Title"
        textField.borderStyle = .roundedRect
        textField.keyboardAppearance = .dark
        textField.backgroundColor = UIColor(hexString: "363636")
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds
        textField.layer.borderColor = UIColor(hexString: "979797")?.cgColor
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 20, weight: .medium)

        // Đặt màu sắc cho placeholder
                let placeholderColor = UIColor.gray
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: placeholderColor,
                    .font: UIFont.systemFont(ofSize: 20) // Đặt font chữ cho placeholder nếu cần thiết
                ]
                textField.attributedPlaceholder = NSAttributedString(string: "Title", attributes: attributes)
       
        // Tạo một UIView trống với kích thước mong muốn
                let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
                textField.leftView = leftView
                textField.leftViewMode = .always // Đảm bảo leftView sẽ luôn hiển thị
                
        return textField
    }()
    
    var descriptionTextField :UITextField = {
        let textField = UITextField()
        textField.placeholder = "Description"
        textField.borderStyle = .roundedRect
        textField.keyboardAppearance = .dark
        textField.backgroundColor = UIColor(hexString: "363636")
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
       
        textField.layer.masksToBounds
        textField.layer.borderColor = UIColor(hexString: "979797")?.cgColor
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 20, weight: .medium)

        
        // Đặt màu sắc cho placeholder
                let placeholderColor = UIColor.gray
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: placeholderColor,
                    .font: UIFont.systemFont(ofSize: 20) // Đặt font chữ cho placeholder nếu cần thiết
                ]
                textField.attributedPlaceholder = NSAttributedString(string: "Description", attributes: attributes)
        // Tạo một UIView trống với kích thước mong muốn
                let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
                textField.leftView = leftView
                textField.leftViewMode = .always // Đảm bảo leftView sẽ luôn hiển thị
                
        return textField
    }()
    
    var dateButton :UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "timer"), for: .normal)
        return button
    }()
    var tagButton :UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "tag"), for: .normal)
        return button
    }()
    var flagButton :UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "flag"), for: .normal)
        return button
    }()
    var sendButton :UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send"), for: .normal)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        calendarCV.setup("CalendarDayCVC", CalendarDayFlowLayout())
        taskCollectionView.setup("PriorityCollectionViewCell", PriorityCollectionViewFlowLayout())
        categoryCollectionView.setup("CategoryCollectionViewCell", CategoryViewFlowLayout())

        refreshTitle()
        refreshButtons()
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(accessoryView)
        accessoryView.addSubview(titleTextField)
        accessoryView.addSubview(descriptionTextField)
        accessoryView.addSubview(addTaskLable)
        accessoryView.addSubview(dateButton)
        accessoryView.addSubview(tagButton)
        accessoryView.addSubview(flagButton)
        accessoryView.addSubview(sendButton)
        
//        accessoryView.isHidden = true
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        // Đăng ký notification khi bàn phím biến mất
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
//        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
//        view.addGestureRecognizer(tapToDismiss)
////
        
        titleTextField.becomeFirstResponder()
        calendarView.isHidden = true
        chooseTimeView.isHidden = true
       taskPriorityView.isHidden = true
        confiugreUI()
       // configureColor()
        self.view.bringSubviewToFront(calendarView)
        dateButton.addTarget(self, action: #selector(choseDateAndTime), for: .touchUpInside)
        flagButton.addTarget(self, action: #selector(chosePriorityFlag), for: .touchUpInside)
        tagButton.addTarget(self, action: #selector(choseCategory), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(createTask), for: .touchUpInside)
//       print( "addCategory \(addCategory.isUserInteractionEnabled)")
        
    }
   
    // MARK: - Functions Date
    @objc func createTask(){
        print("select:  \(selectTimerforTask ?? Date())")
        print("select: " + (selectCategoryforTask ?? ""))
        print("select: " + (selectCategoryColorforTask ?? ""))
        print("select: " + (selectCategoryImageNameforTask ?? ""))
        
        print(titleTextField.text)
        print(descriptionTextField.text)
        print(selectPriorityforTask)
        
        
        if selectTimerforTask == nil{
            showAlertError(message: "Need to choose time")
            return
        }
        if selectCategoryforTask == nil && selectCategoryColorforTask == nil{
            showAlertError(message: "Need to choose category")
            return
        }
        if selectPriorityforTask == nil{
            showAlertError(message: "Need to choose priority")
            return
        }
        guard let title = titleTextField.text else{
            showAlertError(message: "Need to fill text for title")
            return
        }
        guard let description = descriptionTextField.text else{
            showAlertError(message: "Need to fill text for description")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                // 1.
                let managedContext = appDelegate.persistentContainer.viewContext
               
                // 2.
                let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: managedContext)!
                let task = NSManagedObject(entity: entity, insertInto: managedContext)
                
                // 3.

                    task.setValue(title, forKey: "title")
                    task.setValue(description, forKey: "descrip")
                    task.setValue(selectPriorityforTask, forKey: "priority")
                    task.setValue(false, forKey: "status")
                    task.setValue(selectCategoryforTask, forKey: "tag")
                    task.setValue(selectCategoryColorforTask, forKey: "colorCate")
                    task.setValue(selectTimerforTask, forKey: "date")
                    task.setValue(selectCategoryImageNameforTask, forKey: "imagecate")
    
               // 4
               do {
                 try managedContext.save()
                   NotificationCenter.default.post(name: .taskUpdated, object: nil)
                   delegatee?.removeBlurView()
                   DispatchQueue.main.async {
                       self.dismiss(animated: true)
                   }
               } catch let error as NSError {
                 print("Could not save. \(error), \(error.userInfo)")
               }
    }
    
    @objc func choseDateAndTime(){
        calendarView.isHidden = false
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        accessoryView.alpha = 0.35
        isEnableAllSubviews(enable: false)
        
        view.sendSubviewToBack(accessoryView)
        //view.sendSubviewToBack(view)
        view.bringSubviewToFront(calendarCV)
    }
    
    @objc func chosePriorityFlag(){
        taskPriorityView.isHidden = false
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        accessoryView.alpha = 0.35
        isEnableAllSubviews(enable: false)
        view.sendSubviewToBack(accessoryView)
    }
    
    @objc func choseCategory(){
        categoryView.isHidden = false
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        accessoryView.alpha = 0.35
        isEnableAllSubviews(enable: false)
        view.sendSubviewToBack(accessoryView)
//        view.bringSubviewToFront(categoryView)
    }
    
    func reloadValues() {
        refreshTitle()
        refreshButtons()
        calendarCV.reloadData()
    }
    
    func refreshTitle() {
        monthTitleLable.text = dateService.monthTitleText
        yearTitleLable.text = dateService.yearTitleText
    }

    
    func refreshButtons() {
        previousMonthButton.isHidden = dateService.isInMinDate()
        nextMonthButton.isHidden = dateService.isInMaxDate()
    }
    
    func checkSelectedDate() {
        if selectedDate?.isBefore(dateService.minDate) == true || selectedDate?.isAfter(dateService.maxDate) == true {
            selectedDate = nil
            //selectedDateLabel.text = "Selected date: "
        }
    }
    
    
    // MARK: - Actions Date
    
    @IBAction private func previousMonthButton_TUI(_ sender: Any) {
        dateService.goLastMonth()
        reloadValues()
    }
    
    @IBAction private func nextMonthButton_TUI(_ sender: Any) {
        dateService.goNextMonth()
        reloadValues()
    }
    
    @IBAction private func chooseMonthAndYearButton_TUI(_ sender: Any) {
        refreshTitle()
        selectDateMode = !selectDateMode
        if selectDateMode {
            if let monthIndex = dateService.monthsForPicker.firstIndex(of: dateService.date.monthName()) {
                datePickerView.selectRow(monthIndex, inComponent: 0, animated: false)
            }
            if let yearIndex = dateService.yearsForPicker.firstIndex(of: String(dateService.date.year())) {
                datePickerView.selectRow(yearIndex, inComponent: 1, animated: false)
            }
        }
        calendarCV.isHidden = selectDateMode
        previousMonthButton.isHidden = selectDateMode
        nextMonthButton.isHidden = selectDateMode
        daysStackView.isHidden = selectDateMode
        datePickerView.isHidden = !selectDateMode
        if !selectDateMode { reloadValues() }
    }
    
    @IBAction func cancelChooseDate(_ sender: Any) {
        calendarView.isHidden = true
        accessoryView.alpha = 1.0
        isEnableAllSubviews(enable: true)
        titleTextField.becomeFirstResponder()
        view.bringSubviewToFront(accessoryView)
    }
    
    
    @IBAction func chooseTimerofDate(_ sender: Any) {
        calendarView.isHidden = true
        chooseTimeView.isHidden = false
        isEnableAllSubviews(enable: false)
        view.bringSubviewToFront(chooseTimeView)
    }
    
    func isEnableAllSubviews(enable:Bool) {
        titleTextField.isEnabled = enable
        descriptionTextField.isEnabled = enable
        dateButton.isEnabled = enable
        flagButton.isEnabled = enable
        tagButton.isEnabled = enable
        sendButton.isEnabled = enable
    }

    
    @IBAction func cancelChooseTime(_ sender: Any) {
        chooseTimeView.isHidden = true
        calendarView.isHidden = false
        accessoryView.isMultipleTouchEnabled = true
        view.bringSubviewToFront(calendarView)
    }
    
    @IBAction func saveChooseTime(_ sender: Any) {
        
            chooseTimeView.isHidden = true
            accessoryView.alpha = 1

        var selectedTime = timePickerView.date
        
        
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd hh:mm a"
//            let formattedTime = formatter.string(from: selectedTime)
//        
        
            print("Selected time with AM/PM: \(selectedTime)")
        
             selectTimerforTask = selectedTime
        
        
        
            isEnableAllSubviews(enable: true)
            titleTextField.becomeFirstResponder()
        view.bringSubviewToFront(accessoryView)
    }
    
    @IBAction func cancelPriorityButton(_ sender: Any) {
        taskPriorityView.isHidden = true
        titleTextField.becomeFirstResponder()
        view.bringSubviewToFront(accessoryView)
    }
    
    @IBAction func savePriorityButton(_ sender: Any) {
        taskPriorityView.isHidden = true
        accessoryView.alpha = 1
        isEnableAllSubviews(enable: true)
        titleTextField.becomeFirstResponder()
        view.bringSubviewToFront(accessoryView)
    }
    
    @IBAction func addCategoryHandle(_ sender: Any) {
        categoryView.isHidden = true
        isEnableAllSubviews(enable: true)
        accessoryView.alpha = 1
        view.bringSubviewToFront(accessoryView)
    }
    
    
    //--------------------------------------------------------------------------------
    //MARK: Event Keyboard
    
    @objc func tapToDismiss(_ recognizer: UITapGestureRecognizer) {
        if accessoryView.frame.maxY == view.frame.height && calendarView.isHidden == true && taskPriorityView.isHidden == true && categoryView.isHidden == true {
            delegatee?.removeBlurView()
            dismiss(animated: true, completion: nil)
        }
        titleTextField.resignFirstResponder()
        }
    
    
    
    @objc func tapResignKeyboard(){
        titleTextField.resignFirstResponder()
    }
        
    @objc func keyboardWillHide() {
            accessoryView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(0)
            }
        }
    
    @objc func keyboardWillShow(notification: Notification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.height
            
                            accessoryView.snp.updateConstraints { make in
                            make.bottom.equalToSuperview().offset( -keyboardHeight)
                        }
            }
        }

    //----------------------------------------------------------------------------------
    //MARK: contraint layout

    func confiugreUI(){
        chooseTimeButton.layer.cornerRadius = 8
        chooseTimeButton.layer.masksToBounds = true
        
        hourView.layer.cornerRadius = 4
        hourView.layer.masksToBounds = true
        
        minuteView.layer.cornerRadius = 4
        minuteView.layer.masksToBounds = true
        
        halfDayView.layer.cornerRadius = 4
        halfDayView.layer.masksToBounds = true
        
        
        saveTimeButton.layer.cornerRadius = 8
        saveTimeButton.layer.masksToBounds = true
        
        saveTaskPriority.layer.cornerRadius = 8
        saveTaskPriority.layer.masksToBounds = true
        
        categoryView.layer.cornerRadius = 4
        categoryView.layer.masksToBounds = true
        
        addCategory.layer.cornerRadius = 4
        addCategory.layer.masksToBounds = true
        // Đặt màu sắc cho văn bản trong UIDatePicker thành màu trắng
        timePickerView.setValue(UIColor.white, forKeyPath: "textColor")
       
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        
            accessoryView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(228)
            make.bottom.equalToSuperview()
        }
        
            addTaskLable.snp.makeConstraints { make in
            make.top.equalTo(accessoryView.snp.top).offset(25)
            make.leading.equalToSuperview().offset(25)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(addTaskLable.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(43)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(43)
        }
        
        dateButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(25)
            make.height.width.equalTo(24)
        }
        tagButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
            make.leading.equalTo(dateButton.snp.trailing).offset(32)
            make.height.width.equalTo(24)
        }
        flagButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
            make.leading.equalTo(tagButton.snp.trailing).offset(32)
            make.height.width.equalTo(24)
        }
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-25)
            make.height.width.equalTo(24)
        }
    }
}
extension NewPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView{
        case taskCollectionView:
            return 1
        case calendarCV:
            return dateService.numberOfSections
        case categoryCollectionView:
            return 1
        default:
            break
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case taskCollectionView:
            return 10
        case calendarCV:
            return 7
        case categoryCollectionView:
            return categoryName.count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarDate = dateService.getCalendarDate(indexPath)
        switch collectionView{
        case taskCollectionView:
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "PriorityCollectionViewCell", for: indexPath) as! PriorityCollectionViewCell
            cell1.setup(indexPath: indexPath)
            return cell1
        case calendarCV:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCVC", for: indexPath) as! CalendarDayCVC
            cell.setup(calendarDate, selected: calendarDate.date.isEqual(selectedDate))
            return cell
            
        case categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.setupUI(nameCategory: categoryName[indexPath.row], categoryImage: categoryImage[indexPath.row], categoryColor: categoryColor[indexPath.row])
            return cell
        default:
            break
        }
        return UICollectionViewCell()
    }
    
    
    
    //DidSelect
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView{
            
        case taskCollectionView:
            if let cell = collectionView.cellForItem(at: indexPath) as? PriorityCollectionViewCell {
                cell.priorityView.backgroundColor = UIColor(hexString: "8687E7")
                let selectedFlag = indexPath.row + 1
                        
                print("selectedFlag: \(selectedFlag)")
               selectPriorityforTask = "\(selectedFlag)"
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
            
        
            
        case calendarCV:
            print("\(indexPath.row)")
            guard let selectedDate = dateService.daySelected(indexPath) else { return }
            self.selectedDate = selectedDate
            
            print("Selected date: \(selectedDate.toString())")
            timePickerView.setDate(selectedDate, animated: true)
            reloadValues()
            
            
        case categoryCollectionView:
            let totalItems = collectionView.numberOfItems(inSection: indexPath.section)
               print(totalItems)
                
               if indexPath.row == totalItems - 1 {
                   if totalItems == 18 {
                       showAlertError(message: "Need to delete item if you wana add")
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
                
                selectCategoryforTask = categoryName[indexPath.row]
                selectCategoryColorforTask = categoryColor[indexPath.row]
                selectCategoryImageNameforTask = categoryImage[indexPath.row]
            
        default:
            break
        }
    }
    
    func showAlertError( message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
  
}


extension NewPostViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
       return  2
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
        datePickerView.reloadAllComponents()
    }
}

extension NewPostViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
                    descriptionTextField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
                return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
}
