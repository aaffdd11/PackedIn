//
//  PackListsViewController.swift
//  PackedIn
//
//  Created by Yuan Chen on 26/2/15.
//  Copyright (c) 2015 Yuan Chen. All rights reserved.
//

import UIKit
import CoreData

class PackListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var packLists = [PackList]()
    var packList: PackList?
    
    @IBOutlet weak var packListsNavItem: UINavigationItem!
    @IBOutlet weak var newPackListInput: UITextField!
    @IBOutlet weak var packListsTableView: UITableView!
    
    func loadInitialData() {
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"PackList")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [PackList]?
        
        if let results = fetchedResults {
            packLists = results.reverse()
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadInitialData()
        
        self.newPackListInput.delegate = self
        
        packListsTableView.delegate = self
        packListsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "packItemsViewSegue"{
            var packItemsViewController: PackItemsViewController = segue.destinationViewController as PackItemsViewController
            if let indexPath = self.packListsTableView.indexPathForSelectedRow()?.row{
                packItemsViewController.packList = self.packLists[indexPath]
            } else {
                print("failed")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if (countElements(self.newPackListInput.text) > 0) {
            //1
            println("1")
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            //2
            println("2")
            let entity =  NSEntityDescription.entityForName("PackList",
                inManagedObjectContext:
                managedContext)
            
            let packList = PackList(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            //3
            println("3")
            packList.setValue(self.newPackListInput.text, forKey: "name")
            
            //4
            println("4")
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            //5
            println("5")
            packLists.insert(packList, atIndex: 0)
            self.newPackListInput.text = ""
            self.packListsTableView.reloadData()
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return packLists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let tempCell = tableView.dequeueReusableCellWithIdentifier("packListIdentifier", forIndexPath: indexPath) as UITableViewCell
        let packList: PackList = packLists[indexPath.row]
        
        let cell = tempCell.textLabel as UILabel!
        cell.text = packList.name
        
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
