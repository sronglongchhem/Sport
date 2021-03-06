//
//  TimeTableCoreData.swift
//  User
//
//  Created by Chhem Sronglong on 09/04/2019.
//  Copyright © 2019 100456065. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol TitmeTableProtocol {
    func timeTableDidUpdate(data: [TimeTableDate])
}

final class TimeTableCoreData {
    var bookingList : [BookingModel]?
    var list: [TimeTable] = []
    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?
    var delegate : TitmeTableProtocol?
  private  var dataSource = [TimeTableDate]()
    private  var filtered = [TimeTableDate]()
    
  convenience init(userId : String?, delegate : TitmeTableProtocol) {
       self.init()
        self.delegate = delegate
        container = NSPersistentContainer(name: "TimeTable")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    
        if let uid = userId {
                getUserClass(userId: uid)
            
    }

    }
    
    func getUserClass(userId : String) {
        ClassService().bookingList(userId: userId) { bookingList, isError in
            
            if (isError){
                self.fetch()
                return
            }else{
                self.clearDatabase()
                bookingList?.forEach({ bookingModel in
                    let timeTable = TimeTable(context: self.container.viewContext)
                    timeTable.title = bookingModel.className
                    timeTable.level  = Int16(bookingModel.levelType)
                    timeTable.activity = Int16(bookingModel.activityType)
                    timeTable.location = bookingModel.location
                    timeTable.time = bookingModel.classTime
                    timeTable.date = bookingModel.classDate
                })
                self.saveContext()
                self.fetch()
            }
        
            
           
        }
    }
    
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func fetch(){

        do {
            list = try container.viewContext.fetch(TimeTable.fetchRequest())
            print("list count : \(list.count)")
            self.createData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func createData(){
        list.forEach { timeTable in
            
            if let index = dataSource.index(where: {$0.isTheSameDate(date: timeTable.date)}) {
                // do something with foo
                print("same date on index : \(index)")
                var existing = dataSource[index]
                existing.addTimeTable(timeTable: timeTable)
                dataSource[index] = existing
            } else {
                // item could not be found
                print("no same date")
                let model = TimeTableDate(timeTable : timeTable)
                dataSource.append(model)
            }
        }
    
        print("total list: \(dataSource.count)")
        
        
        let month = Date().toMillis()?.toDateWithFormate(format: "MMMM")
        let year = Date().toMillis()?.toDateWithFormate(format: "YYYY")
        self.filterData(month: month!, year: year!)
//        let filter = dataSource.filter { model -> Bool in
//          return  model.month == month && model.year == year
//        }
//
//        self.delegate?.timeTableDidUpdate(data: filter)
    }
    
    func filterData(month : String, year : String){
        filtered = dataSource.filter { model -> Bool in
            return  model.month == month && model.year == year
            }.sorted(by: {$0.getDate() < $1.getDate()})
        
        for index in 0..<filtered.count {
            filtered[index].sort()
        }
        
        self.delegate?.timeTableDidUpdate(data: filtered)
    }
    
    
    func getDataSource() -> [TimeTableDate]{
        return dataSource
    }
    
    func getDetailDataByIndex(index : Int) -> TimeTableDate?{
        if (filtered.count <= 0) {
            return nil
        }else{
            return filtered[index]
        }
    }
    
    public func clearDatabase()
    {
        let url = container.persistentStoreDescriptions.first?.url
        
        guard url != nil else {
            return
        }
        
        let persistentStoreCoordinator = container.persistentStoreCoordinator
        
        do {
            
            try persistentStoreCoordinator.destroyPersistentStore(at:url!, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url!, options: nil)
            print("all clear")
        } catch let _ {
            print("clear error")
//            print(name.uppercased() + ": Clear store: " + error.localizedDescription)
        }
    }
    
    
}
