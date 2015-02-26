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
    
    @IBOutlet weak var packItemsViewTitle: UILabel!
    @IBOutlet weak var newPackItemInput: UITextField!
    @IBOutlet weak var packItemsTableView: UITableView!
    
    func loadInitialData() {
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"PackItem")
//        fetchRequest.predicate = NSPredicate(format: "belongTo = %@", argumentArray: [self.packerListObject!])
        
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
        
        self.newPackItemInput.delegate = self
        
        packItemsTableView.delegate = self
        packItemsTableView.dataSource = self
        packItemsViewTitle.text = self.packItem?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if (countElements(self.newPackItemInput.text) > 0) {
            //1
            println("1")
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            //2
            println("2")
            let entity =  NSEntityDescription.entityForName("PackItem",
                inManagedObjectContext:
                managedContext)
            
            let packItem = PackItem(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            //3
            println("3")
            packItem.setValue(self.newPackItemInput.text, forKey: "name")
            
            //4
            println("4")
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            //5
            println("5")
            packItems.insert(packItem, atIndex: 0)
            self.newPackItemInput.text = ""
            self.packItemsTableView.reloadData()
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return packItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let tempCell = tableView.dequeueReusableCellWithIdentifier("packItemIdentifier", forIndexPath: indexPath) as UITableViewCell
        let packItem: PackItem = packItems[indexPath.row]
        
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
