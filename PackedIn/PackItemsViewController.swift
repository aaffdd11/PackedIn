//
//  PackItemsViewController.swift
//  PackedIn
//
//  Created by Yuan Chen on 26/2/15.
//  Copyright (c) 2015 Yuan Chen. All rights reserved.
//

import UIKit
import CoreData

class PackItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedContext: NSManagedObjectContext?
    var refreshControl: UIRefreshControl!
    
    var packList: PackList?
    
    var packItems = [PackItem]()
    var packItem: PackItem?
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var packListDescInput: UITextField!
    @IBOutlet weak var packItemsNavItem: UINavigationItem!
    @IBOutlet weak var renameTitle: UITextField!
    @IBOutlet weak var newPackItemInput: UITextField!
    @IBOutlet weak var packItemsTableView: UITableView!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    func sortPackItems(this:PackItem, that:PackItem) -> Bool {
        return this.stats.intValue < that.stats.intValue
    }
//    
//    func indexOfFirstCompletedOrNotNeeded() -> Int {
//        var i = 0
//        while i < packItems.count {
//            if packItems[i].stats == 1 || packItems[i] == 2 {
//                return i
//            }
//            i++
//        }
//        return packItems.count
//    }
    
    func updatePackItemLocation(packItem: PackItem, index: Int) {
        packItems.removeAtIndex(index)
        var i = 0
        var indexToInsert = packItems.count
        while i < packItems.count {
            if packItems[i].stats == packItem.stats {
                indexToInsert = i
                break
            } else if packItems[i].stats == 2 {
                indexToInsert = i
                break
            }
            i++
        }
        
        var error : NSError? = nil
        if !self.managedContext!.save(&error) { // 8
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        // insert to the index
        packItems.insert(packItem, atIndex: indexToInsert)
        
        packItemsTableView.reloadData()
        
        
    }
    
    func resetContent(sender: UIBarButtonItem) {
        // update get new array
        var i = 0
        while i < packItems.count {
            packItems[i].stats = 0
            i++
        }
        
        var error : NSError? = nil
        if !self.managedContext!.save(&error) { // 8
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        // reload table
        self.packItemsTableView.reloadData()
        
    }
    
    func loadTableData() {
        
        let fetchRequest = NSFetchRequest(entityName:"PackItem")
        fetchRequest.predicate = NSPredicate(format: "belongTo = %@", argumentArray: [self.packList!])
        
        var error: NSError?
        let fetchedResults = managedContext!.executeFetchRequest(fetchRequest,
            error: &error) as [PackItem]?
        
        if let results = fetchedResults {
            packItems = results.reverse()
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        packItems.sort(sortPackItems)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedContext = appDelegate.managedObjectContext!
        
        // Do any additional setup after loading the view.
        
        self.packListDescInput.delegate = self
        self.renameTitle.delegate = self
        self.newPackItemInput.delegate = self
        
        packItemsTableView.delegate = self
        packItemsTableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "renderView:", forControlEvents: UIControlEvents.AllEvents)
        
        packItemsTableView.registerClass(PackItemsTableViewCell.self, forCellReuseIdentifier: "packItemIdentifier")
        
        renameTitle.text = packList?.name
        packItemsNavItem.title = packList?.name
        
        newPackItemInput.attributedPlaceholder = NSAttributedString(string:"添加小东西",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        if let packList = self.packList? {
            packListDescInput.text = packList.desc
        } else {
            println("no desc yet")
        }
        
        resetButton.target = self
        resetButton.action = "resetContent:"
        
        loadTableData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if (self.renameTitle.text != self.packList?.name) {
            self.packList?.setValue(self.renameTitle.text, forKey: "name")
            var error: NSError?
            if !managedContext!.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            } else {
                println("title renamed")
                packItemsNavItem.title = self.packList?.name
            }
        }
        
        if (countElements(self.newPackItemInput.text) > 0) {
            //1
            
            //2
            let entity =  NSEntityDescription.entityForName("PackItem",
                inManagedObjectContext:
                managedContext!)
            
            let packItem = PackItem(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            //3
            packItem.setValue(self.newPackItemInput.text, forKey: "name")
            packItem.setValue(self.packList, forKey: "belongTo")
            packItem.setValue(0, forKey: "stats")
            
            //4
            var error: NSError?
            if !managedContext!.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            //5
//            packItems.insert(packItem, atIndex: 0)
            self.newPackItemInput.text = ""
            
            packItems.insert(packItem, atIndex: 0)
            
            packItemsTableView.reloadData()
            
        }
        
        if (self.packListDescInput.text != self.packList?.desc) {
            self.packList?.setValue(self.packListDescInput.text, forKey: "desc")
            var error: NSError?
            if !managedContext!.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
        
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return packItems.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: UILabel = UILabel()
        title.backgroundColor = UIColor.clearColor()
        return title
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        let tempCell = tableView.dequeueReusableCellWithIdentifier("packItemIdentifier", forIndexPath: indexPath) as PackItemsTableViewCell
        
        let packItem: PackItem = packItems[indexPath.section]
        
        tempCell.layer.cornerRadius = 5.0
        tempCell.textLabel!.text = packItem.name

        if packItem.stats == 1 {
            tempCell.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 0.5)
        } else if packItem.stats == 2 {
            tempCell.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0, alpha: 0.5)
        } else {
            tempCell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        }
        
        if let font = UIFont(name: "HanziPen SC", size: 15) {
            tempCell.textLabel!.font = font
        } else {
            println("Error loading Font, listing available fonts")
            println(UIFont.familyNames())
        }
        
        return tempCell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        var packItem = managedContext!.objectWithID(self.packItems[indexPath.section].objectID) as PackItem
        
        var resetRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "重置", handler:{action, indexpath in
            
            packItem.stats = 0
            self.updatePackItemLocation(packItem, index: indexPath.section)
            
        })
        
        resetRowAction.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        var noNeedRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "不需要", handler:{action, indexpath in
            
            packItem.stats = 2
            self.updatePackItemLocation(packItem, index: indexPath.section)
            
        })
        
        noNeedRowAction.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0, alpha: 1.0)
        
        var completeRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "完成", handler:{action, indexpath in
            
            packItem.stats = 1
            self.updatePackItemLocation(packItem, index: indexPath.section)
            
        })
        completeRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除", handler:{action, indexpath in
            
            self.managedContext!.deleteObject(packItem)
            self.packItems.removeAtIndex(indexPath.section)
            let sectionIndex: NSIndexSet = NSIndexSet(index: indexPath.section)
            
            self.packItemsTableView.deleteSections(sectionIndex, withRowAnimation: .Fade)
        })
        
        if packItem.stats == 1 {
            return [deleteRowAction, noNeedRowAction, resetRowAction]
        } else if packItem.stats == 2 {
            return [deleteRowAction, resetRowAction, completeRowAction]
        }
        
        return [deleteRowAction, noNeedRowAction, completeRowAction]
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
