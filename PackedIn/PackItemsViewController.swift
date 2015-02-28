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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadInitialData()
        
        self.packListDescInput.delegate = self
        self.newPackItemInput.delegate = self
        
        packItemsTableView.delegate = self
        packItemsTableView.dataSource = self
        
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
        let tempCell = tableView.dequeueReusableCellWithIdentifier("packItemIdentifier", forIndexPath: indexPath) as UITableViewCell
        let packItem: PackItem = packItems[indexPath.section]
        tempCell.layer.cornerRadius = 5.0
        
        let cell = tempCell.textLabel as UILabel!
        cell.text = packItem.name
        
        // Configure the cell...
        
        return tempCell
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
