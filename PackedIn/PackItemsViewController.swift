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
    var packList: PackList?
    
    var packItems = [PackItem]()
    var packItem: PackItem?
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var packListDescInput: UITextField!
    @IBOutlet weak var packItemsNavItem: UINavigationItem!
    @IBOutlet weak var newPackItemInput: UITextField!
    @IBOutlet weak var packItemsTableView: UITableView!
    
    func sortPackItems(this:PackItem, that:PackItem) -> Bool {
        return this.stats.intValue < that.stats.intValue
    }
    
    func updatePackItemLocation(packItem: PackItem, index: Int) {
        packItems.removeAtIndex(index)
        var i = 0
        var indexToInsert = packItems.count
        while i < packItems.count {
            if packItems[i].stats == packItem.stats {
                indexToInsert = i
                break
            }
            i++
        }
        // insert to the index
        packItems.insert(packItem, atIndex: indexToInsert)
        
        packItemsTableView.reloadData()
    }
    
    func findFirstCompleted() -> Int{
        var i:Int = 0
        while i < packItems.count {
            if packItems[i].stats == 1 {
                return i
            }
            i++
        }
        return 0
    }
    
    func loadInitialData() {
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"PackItem")
        fetchRequest.predicate = NSPredicate(format: "belongTo = %@", argumentArray: [self.packList!])
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
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
        
        // Do any additional setup after loading the view.
        loadInitialData()
        
        self.packListDescInput.delegate = self
        self.newPackItemInput.delegate = self
        
        packItemsTableView.delegate = self
        packItemsTableView.dataSource = self
        
        packItemsTableView.registerClass(PackItemsTableViewCell.self, forCellReuseIdentifier: "packItemIdentifier")
        
        packItemsNavItem.title = packList?.name
        
        newPackItemInput.attributedPlaceholder = NSAttributedString(string:"添加小东西",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        if let packList = self.packList? {
            packListDescInput.text = packList.desc
        } else {
            println("no desc yet")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if (countElements(self.newPackItemInput.text) > 0) {
            //1
            let managedContext = appDelegate.managedObjectContext!
            
            //2
            let entity =  NSEntityDescription.entityForName("PackItem",
                inManagedObjectContext:
                managedContext)
            
            let packItem = PackItem(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            //3
            packItem.setValue(self.newPackItemInput.text, forKey: "name")
            packItem.setValue(self.packList, forKey: "belongTo")
            packItem.setValue(0, forKey: "stats")
            
            //4
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            //5
            packItems.insert(packItem, atIndex: 0)
            self.newPackItemInput.text = ""
            self.packItemsTableView.reloadData()
        }
        
        if (self.packListDescInput.text != self.packList?.desc) {
            let managedContext = appDelegate.managedObjectContext!
            self.packList?.setValue(self.packListDescInput.text, forKey: "desc")
            var error: NSError?
            if !managedContext.save(&error) {
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
        
        println(packItem.stats)
        if packItem.stats == 1 {
            tempCell.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 0.5)
        } else if packItem.stats == 2 {
            tempCell.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0, alpha: 0.5)
        }
        
        
        if let font = UIFont(name: "HanziPen SC", size: 15) {
            tempCell.textLabel!.font = font
        } else {
            println("Error loading Font, listing available fonts")
            println(UIFont.familyNames())
        }
        
        return tempCell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //        if editingStyle == .Delete {
        //            self.packItems.removeAtIndex(indexPath.section)
        //            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        //        } else if editingStyle == .Insert {
        //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        //        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        println(indexPath.section)
//        var packItem = self.packItems[indexPath.section]
        let managedContext = appDelegate.managedObjectContext!
        var packItem = managedContext.objectWithID(self.packItems[indexPath.section].objectID) as PackItem
        
        let originalStats = packItem.stats
        
        var noNeedRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "不需要", handler:{action, indexpath in
            println("NONEED•ACTION")
            
            packItem.stats = 2
            
            
            self.updatePackItemLocation(packItem, index: indexPath.section)
        })
        noNeedRowAction.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0, alpha: 1.0)
        
        var completeRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "完成", handler:{action, indexpath in
            println("COMPLETE•ACTION")
            
            packItem.stats = 1
            self.updatePackItemLocation(packItem, index: indexPath.section)
            
        })
        completeRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除", handler:{action, indexpath in
            println("DELETE•ACTION")
            
            let managedContext = self.appDelegate.managedObjectContext!
            managedContext.deleteObject(packItem)
            
            self.packItems.removeAtIndex(indexPath.section)
            
            let sectionIndex: NSIndexSet = NSIndexSet(index: indexPath.section)
            
            self.packItemsTableView.deleteSections(sectionIndex, withRowAnimation: .Fade)
        })
        
        
        
        
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
