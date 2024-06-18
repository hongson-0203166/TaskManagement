//
//  CreateNewCategoryViewController.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 20/05/2024.
//

import UIKit

class CreateNewCategoryViewController: UIViewController,UIGestureRecognizerDelegate{
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var iconFromLibraryButton: UIButton!
    @IBOutlet weak var categoryColorCollectionView: UICollectionView!
    
    @IBOutlet weak var createCategoryButton: UIButton!
    
    @IBOutlet weak var categoryIconView: UIView!
    @IBOutlet weak var categoryChooseIconCollectionView: UICollectionView!

    var completion: (( _ cateName: String, _ cateIcon: String, _ cateColor: String) -> Void)?

    var colorCategory = ["C9CC41", "66CC41", "41CCA7", "4181CC", "41A2CC", "CC8441", "9741CC", "CC4173", "8687E7"]
    var iconCategory = ["airplane", "car", "bus", "tram", "ferry", "key", "fuelpump", "eye", "fan", "carbohydrates", "category", "dog", "freelancer", "hot-pot", "job-rotation" , "luggage", "save-money", "targeting", "animal",  "birthday", "bone", "cat", "event", "fashion", "hospital", "pet-shop", "planning"]

    var selectedIndexPath: IndexPath?
    var cateColor : String?
    var cateIcon : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureUI()

        categoryNameTextField.becomeFirstResponder()
        iconFromLibraryButton.contentEdgeInsets = UIEdgeInsets(top: 8,left: 16,bottom: 8,right: 16)
//
        let guesture = UITapGestureRecognizer(target: self, action: #selector(hideChooseViewIcon))
        guesture.delegate = self
        view.addGestureRecognizer(guesture)
       
    }
    @objc func hideKeyboard(){
        categoryNameTextField.resignFirstResponder()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // Lấy vị trí chạm
            let touchPoint = touch.location(in: view)
        categoryNameTextField.resignFirstResponder()
            // Xác định khu vực chạm (phần trên cùng 1/3 chiều cao màn hình và phần dưới cùng 1/3 chiều cao màn hình)
            let heightTou = view.frame.height / 3 + 10
            let topArea = CGRect(x: 0, y: 0, width: view.frame.width, height: heightTou)
            let bottomArea = CGRect(x: 0, y: view.frame.maxY - heightTou, width: view.frame.width, height: heightTou)
            
            // Kiểm tra xem điểm chạm có nằm trong categoryIconView hay không
            if categoryIconView.frame.contains(touchPoint) {
                // Nếu điểm chạm nằm trong categoryIconView, cho phép view này nhận sự kiện chạm
                return false
            }
            
//            // Kiểm tra xem điểm chạm có nằm trong khu vực xác định không
            if topArea.contains(touchPoint) || bottomArea.contains(touchPoint) {
                // Nếu điểm chạm nằm trong khu vực trên hoặc dưới cùng, cho phép xử lý sự kiện chạm để ẩn categoryIconView
                return true
            }
        
        if  (view != nil){
                    categoryNameTextField.resignFirstResponder()
                    return false
                }
            
            return false
        }
    
        
    @objc func hideChooseViewIcon(_ sender: UITapGestureRecognizer) {
        // Thực hiện ẩn categoryIconView khi chạm vào khu vực trên cùng hoặc dưới cùng của màn hình
        categoryNameTextField.resignFirstResponder()
        categoryIconView.isHidden = true
        categoryNameTextField.isEnabled = true
        categoryColorCollectionView.isUserInteractionEnabled = true
        
    }

    
    
    func configureCollectionView(){
        // Tạo một UICollectionViewFlowLayout mới
           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .horizontal // Đặt hướng cuộn là ngang
           layout.itemSize = CGSize(width: 36, height: 36) // Đặt kích thước của các cell
           layout.minimumLineSpacing = 12 // Khoảng cách giữa các cell theo chiều ngang
        //   layout.minimumInteritemSpacing = 10 // Khoảng cách giữa các cell theo chiều dọc
           
           categoryColorCollectionView.collectionViewLayout = layout
           categoryColorCollectionView.showsHorizontalScrollIndicator = false
        
        
        
        
        // Tạo một UICollectionViewFlowLayout mới
           let layout1 = UICollectionViewFlowLayout()
            layout1.scrollDirection = .vertical // Đặt hướng cuộn là ngang
            layout1.itemSize = CGSize(width: 44, height: 44) // Đặt kích thước của các cell
            layout1.minimumLineSpacing = 12 // Khoảng cách giữa các cell theo chiều ngang
        //   layout.minimumInteritemSpacing = 10 // Khoảng cách giữa các cell theo chiều dọc
           
          
           categoryChooseIconCollectionView.collectionViewLayout = layout1
//       
        
        let nib = UINib(nibName: "ColorCollectionViewCell", bundle: nil)
        categoryColorCollectionView.register(nib, forCellWithReuseIdentifier: "ColorCollectionViewCell")

        
        let nib1 = UINib(nibName: "CategoryIconCollectionViewCell", bundle: nil)
        categoryChooseIconCollectionView.register(nib1, forCellWithReuseIdentifier: "CategoryIconCollectionViewCell")

    }
    
    
    func configureUI(){
        // Tạo NSAttributedString cho placeholder với màu sắc mong muốn
        let placeholderText = "Category name"
        let placeholderColor = UIColor.lightGray // Đổi thành màu bạn muốn
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor
        ]
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftView = leftView
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.attributedPlaceholder = attributedPlaceholder
       
        categoryNameTextField.layer.cornerRadius = 4
        categoryNameTextField.layer.borderWidth = 1
        categoryNameTextField.layer.masksToBounds = true
        categoryNameTextField.layer.borderColor = UIColor(hexString: "FFFFFF", alpha: 0.87)?.cgColor
        
        createCategoryButton.layer.cornerRadius = 4
        createCategoryButton.layer.masksToBounds = true
        
        iconFromLibraryButton.layer.cornerRadius = 6
        iconFromLibraryButton.layer.masksToBounds = true
        
        categoryIconView.layer.cornerRadius = 6
        categoryIconView.layer.masksToBounds = true
    }
    
    

    @IBAction func cancelCreateNewCate(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func categoryCreateHandle(_ sender: Any) {
        let cateName = categoryNameTextField.text
        var error : String?
        if  cateName == "" {
             error = "Fill in the remaining information"
            showAlertError(message: error ?? "")
            return
        }
        if cateIcon == nil{
            error = "Don't choose icon"
            showAlertError(message: error ?? "")
            return
        }
        print(cateIcon)
        if cateColor == nil{
            error = "Don't choose color"
            showAlertError(message: error ?? "")
            return
        }
        
        self.completion?(cateName ?? "", cateIcon ?? "", cateColor ?? "")
        dismiss(animated: true)
      
    }
    
    func showAlertError( message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    @IBAction func categoryIconHandle(_ sender: Any) {
        categoryIconView.isHidden = false
        categoryNameTextField.isEnabled = false
        categoryColorCollectionView.isUserInteractionEnabled = false
    }
    
}


extension CreateNewCategoryViewController: UICollectionViewDelegate,UICollectionViewDataSource{
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case categoryColorCollectionView:
            return colorCategory.count
//            
        case categoryChooseIconCollectionView:
            return iconCategory.count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            case categoryColorCollectionView:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
                    cell.setupUI(color: colorCategory[indexPath.row])
                    cell.chooseColor.isHidden = indexPath != selectedIndexPath
                    return cell
            
            
            case categoryChooseIconCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryIconCollectionViewCell", for: indexPath) as! CategoryIconCollectionViewCell
                    cell.categoryImageView.image = UIImage(named: iconCategory[indexPath.row])
                    cell.categoryImageView.tintColor = .black
                    return cell
            
            default:
                break
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView{
        case categoryColorCollectionView:
            if selectedIndexPath == indexPath {
                       selectedIndexPath = nil
             
            } else {
               
                       let previousIndexPath = selectedIndexPath
                       selectedIndexPath = indexPath
                
                       // Update previously selected cell to hide image
                       if let previous = previousIndexPath {
                           collectionView.reloadItems(at: [previous])
                          
                       }
                   }
                   // Update newly selected cell to show image
                   collectionView.reloadItems(at: [indexPath])
                    print(indexPath.row)
            
            //Xử lý sự kiện
            print("colorCategory: " + colorCategory[indexPath.row])
            cateColor = colorCategory[indexPath.row]
            
            
        case categoryChooseIconCollectionView:
            
            let customIcon = UIImage(named: iconCategory[indexPath.row])?.withRenderingMode(.alwaysOriginal)
            iconFromLibraryButton.setImage(customIcon, for: .normal)
            iconFromLibraryButton.setTitle(nil, for: .normal)
            iconFromLibraryButton.contentEdgeInsets = UIEdgeInsets(top: 9,left: 9,bottom: 9,right: 9)
            categoryIconView.isHidden = true
            categoryNameTextField.isEnabled = true
            categoryColorCollectionView.isUserInteractionEnabled = true
            print("iconCategory: " + iconCategory[indexPath.row])
            cateIcon = iconCategory[indexPath.row]
        default:
            break
        }
           }
    }
    
    
