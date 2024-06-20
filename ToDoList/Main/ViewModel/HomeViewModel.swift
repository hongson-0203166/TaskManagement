//
//  HomeViewModel.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 01/06/2024.
//


import CoreData
import UIKit
import FirebaseFirestoreInternal

class HomeViewModel{
    var tasks: [Task] = []
      var completedTasks: [Task] = []
      var incompleteTasks: [Task] = []
   // var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
    //var safeEmail : String?
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
      let context: NSManagedObjectContext
      
    init() {
          context = appDelegate?.persistentContainer.viewContext ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
          
//        self.safeEmail  = (UserDefaults.standard.string(forKey: "email") ?? "").replacingSpecialCharacters()
        self.tasks = self.fetchTasks()
              
        //  filterTask()
      }
    
    
    
    //MARK: - Fetch Tasks
    func fetchTasks() -> [Task] {
        return fetchTasks1().filter { task in
            task.isdeleted == false
        }
    }

    func fetchTasks1() -> [Task] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do {
            let fetchedTasks = try context.fetch(fetchRequest)
            print(fetchedTasks)
            
            return fetchedTasks.map { task in
                return Task(id: task.id ?? "",
                            colorCate: task.colorCate ?? "",
                            date: task.date ?? Date(),
                            descrip: task.descrip ?? "",
                            imagecate: task.imagecate ?? "",
                            lastUpdated: task.lastUpdated ?? Date(),
                            priority: task.priority ?? "",
                            status: task.status,
                            tag: task.tag ?? "",
                            title: task.title ?? "",
                            isdeleted: task.isdeleted ?? false,
                            reminderIdentifier: task.reminderIdentifier ?? "")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }


    
    func fetchTasksFromFirebase(completion: @escaping ([Task]) -> Void) {
        let db = Firestore.firestore()
        //print(safeEmail)
        var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
        db.collection("\(safeEmail)").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("No documents in Firebase")
                completion([])
                return
            }

            var tasks: [Task] = []
            var taskIds = Set<String>()
            
            for document in documents {
                let data = document.data()
                let id = document.documentID.replacingOccurrences(of: "_", with: "/")
                
                // Kiểm tra trùng lặp ID
                if taskIds.contains(id) {
                    print("Duplicate ID found in Firebase: \(id)")
                    continue
                }
                taskIds.insert(id)
                
                let title = data["title"] as? String ?? ""
                let descrip = data["descrip"] as? String ?? ""
                let priority = data["priority"] as? String ?? ""
                let status = data["status"] as? Bool ?? false
                let tag = data["tag"] as? String ?? ""
                let colorCate = data["colorCate"] as? String ?? ""
                let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                let imagecate = data["imagecate"] as? String ?? ""
                let lastUpdated = (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date()
                let isdeleted = data["isdeleted"] as? Bool ?? false
                let task = Task(
                    id: id,
                    colorCate: colorCate,
                    date: date,
                    descrip: descrip,
                    imagecate: imagecate,
                    lastUpdated: lastUpdated,
                    priority: priority,
                    status: status,
                    tag: tag,
                    title: title,
                    isdeleted: isdeleted
                )

                tasks.append(task)
            }
            
            completion(tasks)
        }
    }

    
    
    
    
    func synchronizeTasks(completion: @escaping ([Task]) -> Void) {
        // Lấy dữ liệu từ Core Data
        let coreDataTasks = fetchTasks1()
        
        // Lấy dữ liệu từ Firebase
        fetchTasksFromFirebase { firebaseTasks in
            // Tạo từ điển để lưu trữ các task từ Core Data và Firebase
            var coreDataDict = Dictionary(uniqueKeysWithValues: coreDataTasks.map { ($0.id, $0) })
            var firebaseDict = Dictionary(uniqueKeysWithValues: firebaseTasks.map { ($0.id, $0) })
            
            // Xử lý các ID trùng lặp và đồng bộ hóa
            for (id, firebaseTask) in firebaseDict {
                if let coreDataTask = coreDataDict[id] {
                    if firebaseTask.isdeleted {
                        self.updateTaskInCoreData(firebaseTask)
                    } else if firebaseTask.lastUpdated > coreDataTask.lastUpdated {
                        self.updateTaskInCoreData(firebaseTask)
                    } else if firebaseTask.lastUpdated < coreDataTask.lastUpdated {
                        self.updateTaskInFirebase(coreDataTask)
                    }
                    coreDataDict.removeValue(forKey: id) // Xóa khỏi từ điển để không lưu lại sau này
                } else {
                    self.saveTaskToCoreData(firebaseTask)
                }
            }
            
            // Lưu lại các task còn lại trong Core Data mà không có trong Firebase
            for (id, coreDataTask) in coreDataDict {
                self.saveTaskToFirebase(coreDataTask)
            }
            
            // Đảm bảo không có bản ghi nào bị lặp trong Core Data
            let updatedCoreDataTasks = self.fetchTasks1().filter { !$0.isdeleted }
            completion(updatedCoreDataTasks)
        }
    }
    func updateTaskInCoreData(_ task: Task) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
        do {
            if let fetchedTask = try context.fetch(fetchRequest).first {
                fetchedTask.colorCate = task.colorCate
                fetchedTask.date = task.date
                fetchedTask.descrip = task.descrip
                fetchedTask.imagecate = task.imagecate
                fetchedTask.lastUpdated = task.lastUpdated
                fetchedTask.priority = task.priority
                fetchedTask.status = task.status
                fetchedTask.tag = task.tag
                fetchedTask.title = task.title
                fetchedTask.isdeleted = task.isdeleted
                try context.save()
            }
        } catch let error as NSError {
            print("Could not update CoreData task. \(error), \(error.userInfo)")
        }
    }

    func updateTaskInFirebase(_ task: Task) {
        let db = Firestore.firestore()
        let taskId = task.id.replacingOccurrences(of: "/", with: "_")
        let taskData: [String: Any] = [
            "colorCate": task.colorCate,
            "date": task.date,
            "descrip": task.descrip,
            "imagecate": task.imagecate,
            "lastUpdated": task.lastUpdated,
            "priority": task.priority,
            "status": task.status,
            "tag": task.tag,
            "title": task.title,
            "isdeleted": task.isdeleted
        ]
        var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
        db.collection("\(safeEmail)").document(taskId).setData(taskData) { error in
            if let error = error {
                print("Could not update Firebase task. \(error.localizedDescription)")
            }
        }
    }

    func saveTaskToCoreData(_ task: Task) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
        
        do {
            let existingTasks = try context.fetch(fetchRequest)
            if let existingTask = existingTasks.first {
                // Đối tượng đã tồn tại trong Core Data, cập nhật thuộc tính của nó
                existingTask.colorCate = task.colorCate
                existingTask.date = task.date
                existingTask.descrip = task.descrip
                existingTask.imagecate = task.imagecate
                existingTask.lastUpdated = task.lastUpdated
                existingTask.priority = task.priority
                existingTask.status = task.status
                existingTask.tag = task.tag
                existingTask.title = task.title
                existingTask.isdeleted = task.isdeleted
            } else {
                // Đối tượng chưa tồn tại trong Core Data, tạo mới và lưu
                let newTask = Tasks(context: context)
                newTask.id = task.id
                newTask.colorCate = task.colorCate
                newTask.date = task.date
                newTask.descrip = task.descrip
                newTask.imagecate = task.imagecate
                newTask.lastUpdated = task.lastUpdated
                newTask.priority = task.priority
                newTask.status = task.status
                newTask.tag = task.tag
                newTask.title = task.title
                newTask.isdeleted = task.isdeleted
            }
            
            // Lưu context
            try context.save()
        } catch let error as NSError {
            print("Could not save CoreData task. \(error), \(error.userInfo)")
        }
    }


    func saveTaskToFirebase(_ task: Task) {
        let db = Firestore.firestore()
        let taskId = task.id.replacingOccurrences(of: "/", with: "_")
        let taskData: [String: Any] = [
            "colorCate": task.colorCate,
            "date": task.date,
            "descrip": task.descrip,
            "imagecate": task.imagecate,
            "lastUpdated": task.lastUpdated,
            "priority": task.priority,
            "status": task.status,
            "tag": task.tag,
            "title": task.title,
            "isdeleted": task.isdeleted
        ]
        var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
        db.collection("\(safeEmail)").document(taskId).setData(taskData) { error in
            if let error = error {
                print("Could not save Firebase task. \(error.localizedDescription)")
            }
        }
    }

    
            
    
    func deleteAllData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator

        // Fetch all entities in the model
        if let entities = persistentStoreCoordinator.managedObjectModel.entities as [NSEntityDescription]? {
            for entity in entities {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
                fetchRequest.includesPropertyValues = false

                do {
                    let items = try context.fetch(fetchRequest) as! [NSManagedObject]
                    for item in items {
                        context.delete(item)
                    }
                } catch {
                    print("Failed to fetch items for entity \(entity.name!): \(error)")
                }
            }
        }
        do {
            try context.save()
            print("Successfully deleted all data from Core Data")
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }
    
    //MARK: - Filter Task

    
    
    
    
    
    
     //MARK: - Update Task Status
    func updateTask(_ task: Task) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        print("Task ID to update:", task.id)

        // Find the task in Core Data based on its ID
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
        
        do {
            if let objectToUpdate = try context.fetch(fetchRequest).first {
                // Update task attributes
                objectToUpdate.status = task.status
                objectToUpdate.title = task.title
                objectToUpdate.descrip = task.descrip
                objectToUpdate.priority = task.priority
                objectToUpdate.status = task.status
                objectToUpdate.tag = task.tag
                objectToUpdate.colorCate = task.colorCate
                objectToUpdate.date = task.date
                objectToUpdate.imagecate = task.imagecate
                objectToUpdate.lastUpdated = Date()
                
                try context.save()
                
                // Check network connectivity
                if NetworkState.shared.isConnected() {
                    print("Network connected")
                    // Update the task in Firebase
                    updateTaskwithFirebase(task)
                } else {
                    // Store the delete action for later synchronization
                    let syncAction = SyncAction(context: context)
                    syncAction.actionType = "update"
                    syncAction.taskId = task.id.replacingOccurrences(of: "/", with: "_")
                    try context.save()
                    print("Stored sync action for later")
                    
                }
                
                print("Task updated successfully")
            } else {
                print("No matching task found in Core Data")
            }
        } catch let error as NSError {
            print("Could not update task. \(error), \(error.userInfo)")
        }
        
        NotificationCenter.default.post(name: .syncPendingActions, object: nil)
    }

    
    func updateTaskwithFirebase(_ task: Task) {
        let db = Firestore.firestore()
        let taskId = task.id.replacingOccurrences(of: "/", with: "_") // Chuẩn bị ID của nhiệm vụ cho Firebase
        print("TaskID for update: \(taskId)")
        // Dữ liệu cập nhật của nhiệm vụ
        let updatedData: [String: Any] = [
            "title": task.title,
            "descrip": task.descrip,
            "priority": task.priority,
            "status": task.status,
            "tag": task.tag,
            "colorCate": task.colorCate,
            "date": task.date,
            "imagecate": task.imagecate,
            "lastUpdated": task.lastUpdated
        ]
        var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
        print(safeEmail)
        // Thực hiện cập nhật dữ liệu của nhiệm vụ trong Firestore
        db.collection("\(safeEmail)").document(taskId).setData(updatedData, merge: true) { error in
            if let error = error {
                print("Error updating task in Firestore: \(error)")
            } else {
                print("Task updated successfully in Firestore")
            }
        }
    }
    
    
    
    
    
    //MARK: - Update Action with Firebase when connected network
    func syncPendingActions() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SyncAction> = SyncAction.fetchRequest()
        
        do {
            let syncActions = try context.fetch(fetchRequest)
            let db = Firestore.firestore()
            print(syncActions)
            
            for syncAction in syncActions {
                guard let actionType = syncAction.actionType, let taskId = syncAction.taskId else { continue }
                
                if actionType == "delete" {
                    var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
                    db.collection("\(safeEmail)").document(taskId).updateData(["isdeleted": true]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document successfully removed after reconnection!")
                            context.delete(syncAction)
                            try? context.save()
                        }
                    }
                } else if actionType == "add" {
                    // Find the task in Core Data based on its ID
                    let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", taskId.replacingOccurrences(of: "_", with: "/"))
                    
                    do {
                        if let taskToAdd = try context.fetch(fetchRequest).first {
                            let data: [String: Any] = [
                                "title": taskToAdd.title ?? "",
                                "descrip": taskToAdd.descrip ?? "",
                                "priority": taskToAdd.priority ?? "",
                                "status": taskToAdd.status,
                                "tag": taskToAdd.tag ?? "",
                                "colorCate": taskToAdd.colorCate ?? "",
                                "date": taskToAdd.date ?? Date(),
                                "imagecate": taskToAdd.imagecate ?? "",
                                "lastUpdated": taskToAdd.lastUpdated ?? Date(),
                                "isdeleted": taskToAdd.isdeleted ?? false
                            ]
                            var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
                            db.collection("\(safeEmail)").document(taskId.replacingOccurrences(of: "/", with: "_")).setData(data) { error in
                                if let error = error {
                                    print("Error adding document to Firebase: \(error)")
                                } else {
                                    print("Document successfully added after reconnection!")
                                    context.delete(syncAction)
                                    try? context.save()
                                }
                            }
                        } 
//                        else {
//                            print("No matching task found in Core Data to add.")
//                            context.delete(syncAction)
//                            try? context.save()
//                        }
                    } catch let error as NSError {
                        print("Could not fetch task to add. \(error), \(error.userInfo)")
                    }
                }else if actionType == "update"{
                    // Find the task in Core Data based on its ID
                    let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", taskId.replacingOccurrences(of: "_", with: "/"))
                    do {
                        if let taskToAdd = try context.fetch(fetchRequest).first {
                            print(taskToAdd)
                            let data: [String: Any] = [
                                "title": taskToAdd.title ?? "",
                                "descrip": taskToAdd.descrip ?? "",
                                "priority": taskToAdd.priority ?? "",
                                "status": taskToAdd.status,
                                "tag": taskToAdd.tag ?? "",
                                "colorCate": taskToAdd.colorCate ?? "",
                                "date": taskToAdd.date ?? Date(),
                                "imagecate": taskToAdd.imagecate ?? "",
                                "lastUpdated": taskToAdd.lastUpdated ?? Date()
                            ]
                            var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
                            db.collection("\(safeEmail)").document(taskId.replacingOccurrences(of: "/", with: "_")).setData(data) { error in
                                if let error = error {
                                    print("Error adding document to Firebase: \(error)")
                                } else {
                                    print("Document successfully update after reconnection!")
                                    context.delete(syncAction)
                                    try? context.save()
                                }
                            }
                        }
//                        else {
//                            print("No matching task found in Core Data to add.")
//                            context.delete(syncAction)
//                            try? context.save()
//                        }
                    } catch let error as NSError {
                        print("Could not fetch task to add. \(error), \(error.userInfo)")
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch sync actions. \(error), \(error.userInfo)")
        }
    }

    
    
    //MARK: - Delete Task
                 
  

    func deleteTask(_ task: Task) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        print("Task ID of Model Task:", task.id)
        
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
        
        do {
            if let objectToUpdate = try context.fetch(fetchRequest).first {
                let firebaseTaskId = task.id.replacingOccurrences(of: "/", with: "_")

                // Update the isdeleted field to true
                objectToUpdate.isdeleted = true
                try context.save()
                print("Task marked as deleted in Core Data")

                if NetworkState.shared.isConnected() {
                    print("Network connected")
                    let db = Firestore.firestore()
                    print("taskID for Firebase: \(firebaseTaskId)")
                    var safeEmail = (UserDefaults.standard.string(forKey: "email") ?? "___").replacingSpecialCharacters()
                    db.collection("\(safeEmail)").document(firebaseTaskId).updateData(["isdeleted": true]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document successfully updated!")
                        }
                    }
                } else {
                    // Store the delete action for later synchronization
                    let syncAction = SyncAction(context: context)
                    syncAction.actionType = "delete"
                    syncAction.taskId = firebaseTaskId
                    try context.save()
                    print("Stored sync action for later")
                    print(syncAction)
                }
            } else {
                print("No matching task found in Core Data")
            }
        } catch let error as NSError {
            print("Could not update task. \(error), \(error.userInfo)")
        }
        NotificationCenter.default.post(name: .syncPendingActions, object: nil)
    }

    // Filter tasks by date
    func filterTasksByDate(_ tasks: [Task], dateFilter: (Date) -> Bool) -> [Task] {
        return tasks.filter { task in
            guard let date = task.date as? Date else { return false }
            return dateFilter(date)
        }
    }
//    x-coredata:___Tasks_tA0944565-B96B-490B-9146-F24317EED98B2

    func isDateInToday(_ date: Date, currentDate: Date) -> Bool {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let taskComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return currentComponents.year == taskComponents.year &&
               currentComponents.month == taskComponents.month &&
               currentComponents.day == taskComponents.day
    }

    
    func isDateInCurrentWeek(_ date: Date, currentDate: Date) -> Bool {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) else {
            return false
        }
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return false
        }
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
