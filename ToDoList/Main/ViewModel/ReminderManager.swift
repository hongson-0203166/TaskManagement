//
//  ReminderManager.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 13/06/2024.
//

import Foundation
import EventKit
import UIKit
import CoreData
class ReminderManager{
    var viewModel = HomeViewModel()
    private let eventStore = EKEventStore()
    // Request access to reminders
    func requestRemindersAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .reminder) { (granted, error) in
            if granted {
                completion(true)
            } else {
                if let error = error {
                    print("Error requesting access to reminders: \(error.localizedDescription)")
                } else {
                    print("Access to reminders not granted.")
                }
                completion(false)
            }
        }
    }
    
    
    // Create or update reminders based on tasks from CoreData
    func syncTasksWithReminders() {
        let tasks = viewModel.fetchTasks1()

        print(tasks)
        
        requestRemindersAccess { granted in
            guard granted else { return }

            for task in tasks {
                if task.isdeleted {
                    self.deleteReminder(for: task)
                    
                } else {
                    self.createOrUpdateReminder(for: task)
                    
                }
            }
        }
    }
    
    
    
    // Create or update a reminder based on task data
       private func createOrUpdateReminder(for task: Task) {
           guard let reminderIdentifier = task.reminderIdentifier else {
               createReminder(for: task)
               return
           }

           if let reminder = eventStore.calendarItem(withIdentifier: reminderIdentifier) as? EKReminder {
               updateReminder(reminder, with: task)
           } else {
               createReminder(for: task)
           }
       }

       // Create a new reminder
       private func createReminder(for tasks: Task) {
           var task = tasks
           guard let reminderDate = task.date as? Date else {
               print("No date for task: \(task.title)")
               return
           }

           let reminder = EKReminder(eventStore: eventStore)
           reminder.title = task.title
           reminder.dueDateComponents = Calendar.current.dateComponents(
               [.year, .month, .day, .hour, .minute],
               from: reminderDate
           )

           if let defaultReminderCalendar = eventStore.defaultCalendarForNewReminders() {
               reminder.calendar = defaultReminderCalendar

               do {
                   try eventStore.save(reminder, commit: true)
                   
                   let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                   let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
                   fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
                   do {
                       if let fetchedTask = try context.fetch(fetchRequest).first {
                           fetchedTask.reminderIdentifier = reminder.calendarItemIdentifier
                           try context.save()
                       }
                   } catch let error as NSError {
                       print("Could not update CoreData task. \(error), \(error.userInfo)")
                   }
                   print("Reminder added successfully for task: \(task.title)")
               } catch {
                   print("Error adding reminder for task \(task.title): \(error.localizedDescription)")
               }
           } else {
               print("No default reminder calendar found.")
           }
       }

       // Update an existing reminder
       private func updateReminder(_ reminder: EKReminder, with task: Task) {
           reminder.title = task.title
           if let reminderDate = task.date as? Date {
               reminder.dueDateComponents = Calendar.current.dateComponents(
                   [.year, .month, .day, .hour, .minute],
                   from: reminderDate
               )
           }

           do {
               try eventStore.save(reminder, commit: true)
               print("Reminder updated successfully for task: \(task.title)")
           } catch {
               print("Error updating reminder for task \(task.title): \(error.localizedDescription)")
           }
       }

       // Delete a reminder
       private func deleteReminder(for task1: Task) {
           var task = task1
           guard let reminderIdentifier = task.reminderIdentifier else {
               print("No reminder identifier for task: \(task.title)")
               return
           }

           if let reminder = eventStore.calendarItem(withIdentifier: reminderIdentifier) as? EKReminder {
               do {
                   try eventStore.remove(reminder, commit: true)
                   task.reminderIdentifier = nil
                   print("Reminder deleted successfully for task: \(task.title)")
               } catch {
                   print("Error deleting reminder for task \(task.title): \(error.localizedDescription)")
               }
           } else {
               print("No reminder found with identifier: \(reminderIdentifier)")
           }
       }
    
    
    // Fetch reminders for the current date
       func fetchRemindersForCurrentDate(completion: @escaping ([EKReminder]) -> Void) {
           requestRemindersAccess { granted in
               guard granted else {
                   completion([])
                   return
               }

               let calendars = self.eventStore.calendars(for: .reminder)
               let startOfDay = Calendar.current.startOfDay(for: Date())
               let endOfDay = Calendar.current.date(byAdding: .day, value: 2, to: startOfDay)!

               let predicate = self.eventStore.predicateForReminders(in: calendars)
               self.eventStore.fetchReminders(matching: predicate) { reminders in
                   let todayReminders = reminders?.filter { reminder in
                       if let dueDate = reminder.dueDateComponents?.date {
                           return  dueDate < endOfDay
                       }
                       return false
                   } ?? []
                  
                   
                   completion(todayReminders)
               }
           }
       }
}
