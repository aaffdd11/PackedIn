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
    var managedContext: NSManagedObjectContext?
    
    var packLists = [PackList]()
    var packList: PackList?
    
    @IBOutlet weak var packListsNavItem: UINavigationItem!
    @IBOutlet weak var newPackListInput: UITextField!
    @IBOutlet weak var packListsTableView: UITableView!
    
    @IBAction func unWind(segue:UIStoryboardSegue){
        // This line can be improved. does not have to loadInitialData every time.
        self.packListsTableView.reloadData()
    }
//    
//    func loadFakeData(){
//        var listNames: [String] = ["野营", "朋友家留宿", "出国游", "简单两日周边游", "出远门"]
//        var listDescs: [String] = ["爬山，郊游", "住个一两天", "这必须要记得不能忘记东西啊", "注意住宿卫生", "住酒店啦，离家远，许多东西不能忘记"]
//        var itemNames: [String] = [
//            "瑞士军刀",
//            "墨镜",
//            "花露水",
//            "杀菌液",
//            "创口贴",
//            "云南白药",
//            "游泳眼镜",
//            "泳衣",
//            "水壶",
//            "零食防饥饿",
//            "暖和的大衣或小被子",
//            "帽子",
//            "牙刷牙膏",
//            "防风眼镜",
//            "防潮垫",
//            "帐篷"
//        ]
//        while listNames.count > 0 {
//            let entity =  NSEntityDescription.entityForName("PackList",
//                inManagedObjectContext:
//                managedContext!)
//            
//            let packList = PackList(entity: entity!,
//                insertIntoManagedObjectContext:managedContext)
//            
//            //3
//            var tempName = listNames.removeLast()
//            var tempDesc = listDescs.removeLast()
//            packList.setValue(tempName, forKey: "name")
//            packList.setValue(tempDesc, forKey: "desc")
//            
//            if listNames.count == 0{
//                while itemNames.count > 0{
//                    let itementity =  NSEntityDescription.entityForName("PackItem",
//                        inManagedObjectContext:
//                        managedContext!)
//                    
//                    let packItem = PackItem(entity: itementity!,
//                        insertIntoManagedObjectContext:managedContext)
//                    var tempitemname = itemNames.removeLast() as String
//                    println(tempitemname)
//                    println(packItem.objectID)
//                    packItem.setValue(tempitemname, forKey: "name")
//                    packItem.setValue(packList, forKey: "belongTo")
//
//                }
//            }
//            
//            //4
//            var error: NSError?
//            if !managedContext!.save(&error) {
//                println("Could not save \(error), \(error?.userInfo)")
//            }
//            
//            //5
////            packLists.insert(packList, atIndex: 0)
//
//        }
//    }
    
    func loadInitialData() {
        let fetchRequest = NSFetchRequest(entityName:"PackList")
        var error: NSError?
        let fetchedResults = managedContext!.executeFetchRequest(fetchRequest,
            error: &error) as [PackList]?
        
        if let results = fetchedResults {
            packLists = results.reverse()
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedContext = appDelegate.managedObjectContext!
        
        // Do any additional setup after loading the view.
//        loadFakeData()
        loadInitialData()
        
        self.newPackListInput.delegate = self
        
        packListsTableView.delegate = self
        packListsTableView.dataSource = self
        
        if let navCtrller = self.navigationController {
            navCtrller.navigationBar.setBackgroundImage(UIImage(named: "header-bg"), forBarMetrics: UIBarMetrics.Default)
            navCtrller.navigationBar.shadowImage = UIImage(named: "header-shadow")
            navCtrller.navigationBar.translucent = true
            
            if let font = UIFont(name: "HanziPen SC", size: 20) {
                navCtrller.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
            } else {
                println("Error loading Font, listing available fonts")
                println(UIFont.familyNames())
            }
        } else {
            println("error loading navcontroller")
        }
        
        newPackListInput.attributedPlaceholder = NSAttributedString(string:"创建小清单",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "packItemsViewSegue"{
            var packItemsViewController: PackItemsViewController = segue.destinationViewController as PackItemsViewController
            
            if let indexPath = self.packListsTableView.indexPathForSelectedRow() {
                packItemsViewController.packList = self.packLists[indexPath.section]
            } else {
                print("failed")
            }

        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if (countElements(self.newPackListInput.text) > 0) {
            //1
            //2
            let entity =  NSEntityDescription.entityForName("PackList",
                inManagedObjectContext:
                managedContext!)
            
            let packList = PackList(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            //3
            packList.setValue(self.newPackListInput.text, forKey: "name")
            packList.setValue("", forKey: "desc")
            
            //4
            var error: NSError?
            if !managedContext!.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            //5
            packLists.insert(packList, atIndex: 0)
            self.newPackListInput.text = ""
            self.packListsTableView.reloadData()
        }
        
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return packLists.count
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            switch editingStyle {
            case .Delete:
                // remove the deleted item from the model
                var listToDelete:PackList = self.packLists.removeAtIndex(indexPath.section)
                
                /////// delete the containing items
                var itemsToDelete: [PackItem]
                
                let fetchRequest = NSFetchRequest(entityName:"PackItem")
                fetchRequest.predicate = NSPredicate(format: "belongTo = %@", argumentArray: [listToDelete])
                
                var error: NSError?
                let fetchedResults = managedContext!.executeFetchRequest(fetchRequest,
                    error: &error) as [PackItem]?
                
                if let results = fetchedResults {
                    itemsToDelete = results
                    
                    while itemsToDelete.count > 0 {
                        managedContext!.deleteObject(itemsToDelete.removeLast() as PackItem)
                    }
                } else {
                    println("Could not fetch \(error), \(error!.userInfo)")
                }
                
                self.managedContext!.deleteObject(listToDelete)
                
                var saveError : NSError? = nil
                if !self.managedContext!.save(&error) { // 8
                    NSLog("Unresolved error \(saveError), \(saveError!.userInfo)")
                    abort()
                }
                
                let sectionIndex: NSIndexSet = NSIndexSet(index: indexPath.section)
                self.packListsTableView.deleteSections(sectionIndex, withRowAnimation: .Fade)
            default:
                return
            }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let tempCell = tableView.dequeueReusableCellWithIdentifier("packListIdentifier", forIndexPath: indexPath) as UITableViewCell
        let packList: PackList = packLists[indexPath.section]
        tempCell.layer.cornerRadius = 5.0

        let cell = tempCell.textLabel as UILabel!
        cell.text = packList.name
        
        let subtitle = tempCell.detailTextLabel as UILabel!
        subtitle.text = packList.desc
        
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
