//
//  GroupingTableViewController.swift
//  DragNDrop
//
//  Created by Josh O'Connor on 10/20/16.
//  Copyright (c) 2016 Josh O'Connor. All rights reserved.
//

import UIKit

class GroupingTableViewController: UITableViewController {
    
    var teamDictionary: [Int : String] = [:]
    var foldersList: [String : [Cell]] = [:]  //this will be [folderId: [teams]].  In our project it will be [folderID: [Media]]
    var itemsArray : [String]
    var finishedMovingItem: Bool = true
    var cellBeingMoved: Cell?
    var previousHighlightedCell: Cell?
    fileprivate var lastInitialIndexPath : IndexPath? = nil
    
    required init(coder aDecoder: NSCoder) {
        itemsArray = [String]()
        
        let item1 = "San Francisco 49ers"
        let item2 = "Carolina Panthers"
        let item3 = "Denver Broncos"
        let item4 = "Green Bay Packers"
        let item5 = "Oakland Raiders"
        let item6 = "Cleveland Browns"
        let item7 = "San Diego Chargers"
        let item8 = "Kansa City Chiefs"
        let item9 = "Seattle Seahawks"
        let item10 = "Arizona Cardinals"
        
        itemsArray.append(item1)
        itemsArray.append(item2)
        itemsArray.append(item3)
        itemsArray.append(item4)
        itemsArray.append(item5)
        itemsArray.append(item6)
        itemsArray.append(item7)
        itemsArray.append(item8)
        itemsArray.append(item9)
        itemsArray.append(item10)
        
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<itemsArray.count {
            if teamDictionary[i] == nil {
                teamDictionary[i] = itemsArray[i]
            }
        }
        print(teamDictionary)
        
        
        self.tableView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "FolderCell")// CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        self.tableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "ReuseableCell")// CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(GroupingTableViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct CellBeingMoved {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            finishedMovingItem = false
            if indexPath != nil {
                previousHighlightedCell = nil
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!) as? Cell
                
                CellBeingMoved.cellSnapshot = snapshotOfCell(cell!)
                var center = cell?.center
                CellBeingMoved.cellSnapshot!.center = center!
                CellBeingMoved.cellSnapshot!.alpha = 0.0
                tableView.addSubview(CellBeingMoved.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    print("BEGIN DRAG AND DROP")
                    self.cellBeingMoved = cell
                    center?.y = locationInView.y
                    CellBeingMoved.cellIsAnimating = true
                    CellBeingMoved.cellSnapshot!.center = center!
                    CellBeingMoved.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    CellBeingMoved.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        if finished {
                            CellBeingMoved.cellIsAnimating = false
                        }
                })
            }
            
        case UIGestureRecognizerState.changed:
            if CellBeingMoved.cellSnapshot != nil {
                var center = CellBeingMoved.cellSnapshot!.center
                center.y = locationInView.y
                CellBeingMoved.cellSnapshot!.center = center
                
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    previousHighlightedCell?.backgroundColor = UIColor.clear
                    lastInitialIndexPath = Path.initialIndexPath
                    let cell = tableView.cellForRow(at: indexPath!) as? Cell
                    cell?.backgroundColor = UIColor.lightGray
                    previousHighlightedCell = cell
                    self.tableView.reloadRows(at: [Path.initialIndexPath!], with: .automatic)
                }else if (indexPath == nil){
                    previousHighlightedCell?.backgroundColor = UIColor.clear
                }
            }
        default:
            if Path.initialIndexPath != nil {
                finishedMovingItem = true
                previousHighlightedCell?.backgroundColor = UIColor.clear
                if (indexPath != nil && (indexPath != Path.initialIndexPath)) {
                    
                    
                    // folderID : [teams]
                    // "AFC West" : ["Oakland Raiders", "Kansas City Chiefs", "Denver Broncos", "San Diego Chargers"]
                    let confirmFollowingAlertView = FolderDialog(
                        frame: CGRect(x: 0, y: 0, width: 290, height: 180)
                    )
                    confirmFollowingAlertView.layer.cornerRadius = 5.0
                    self.view.addSubview(confirmFollowingAlertView)
                    confirmFollowingAlertView.center.x = self.tableView.center.x
                    confirmFollowingAlertView.center.y = self.tableView.center.y - 45
                    confirmFollowingAlertView.confirmBlock = { confirmed, folderName in

                        
                        if confirmed == true && folderName != nil {
                            if let folderName = folderName {
                                print("CREATING FOLDER: \(folderName)")
                                print("            cellBeingMoved-> \(self.cellBeingMoved?.teamLabel.text)")
                                print("            previousHighlightedCell-> \(self.previousHighlightedCell?.teamLabel.text)")
                                
                                confirmFollowingAlertView.removeFromSuperview()
                                
                                if (self.foldersList[folderName] == nil) {
                                    self.foldersList[folderName] = [self.cellBeingMoved!, self.previousHighlightedCell!]
                                    print("Folders list:\(self.foldersList)")
                                    
                                    self.itemsArray.remove(at: (Path.initialIndexPath! as NSIndexPath).row)
                                    self.itemsArray.remove(at: self.tableView.indexPath(for: self.previousHighlightedCell!)!.row)

                                    
                                    if let teamBeingMoved = self.cellBeingMoved?.teamLabel.text, let teamSelected = self.previousHighlightedCell?.teamLabel.text {
                                         self.itemsArray.insert("Folder: \(teamBeingMoved), \(teamSelected)", at: (indexPath! as NSIndexPath).row)
                                    }
                                   
                                    self.tableView.reloadData()
                                    Path.initialIndexPath = indexPath
                                    
                                    let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
                                    
                                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                        CellBeingMoved.cellSnapshot!.center = (cell?.center)!
                                        CellBeingMoved.cellSnapshot!.transform = CGAffineTransform.identity
                                        CellBeingMoved.cellSnapshot!.alpha = 0.0
                                        cell?.alpha = 1.0
                                        
                                        }, completion: { (finished) -> Void in
                                            if finished {
                                                Path.initialIndexPath = nil
                                                CellBeingMoved.cellSnapshot!.removeFromSuperview()
                                                CellBeingMoved.cellSnapshot = nil
                                            }
                                    })

                                }
                                
                                
                                
                                
   
                                
                                
//                                self.itemsArray.insert(self.itemsArray.remove(at: (Path.initialIndexPath! as NSIndexPath).row), at: (indexPath! as NSIndexPath).row)
//                                self.tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
//                                self.tableView.reloadData()
//                                Path.initialIndexPath = indexPath
//                                
//                                let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
//                                
//                                UIView.animate(withDuration: 0.25, animations: { () -> Void in
//                                    CellBeingMoved.cellSnapshot!.center = (cell?.center)!
//                                    CellBeingMoved.cellSnapshot!.transform = CGAffineTransform.identity
//                                    CellBeingMoved.cellSnapshot!.alpha = 0.0
//                                    cell?.alpha = 1.0
//                                    
//                                    }, completion: { (finished) -> Void in
//                                        if finished {
//                                            Path.initialIndexPath = nil
//                                            CellBeingMoved.cellSnapshot!.removeFromSuperview()
//                                            CellBeingMoved.cellSnapshot = nil
//                                        }
//                                })
                            }
                        }else if confirmed ==  true && folderName == nil {
                            let alertController = UIAlertController(title: "Whoops!", message: "Please input a folder name.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion:nil)

                        }
                        
                        else{
                            confirmFollowingAlertView.removeFromSuperview()
                            Path.initialIndexPath = nil
                            CellBeingMoved.cellSnapshot!.removeFromSuperview()
                            CellBeingMoved.cellSnapshot = nil
                            self.tableView.reloadData()
                        }
                        
                    }
                    

                    //TO DO:  
                        //1) COMBINE CELLS:
                            //TO DO THIS, WE NEED TO ADD cellBeingMoved AND previousHighlightedCell INTO foldersList DICTIONARY.
                            //REMOVE CELLS FROM TABLEVIEW (IN CELLFORROW, IF CELL == FOLDERSLISTCELL, DONT ADD IT)
                            //CREATE FOLDERCELL, ADD CELLS REMOVED TO FOLDER CELL (NEED TO ADD VAR: dropDownCells IN FOLDERCELL WHICH CONTAINS CELLS CONTAINED INSIDE)
                                //VERIFY THE DATA IN dropDownCells is the data of cells not visible
                        //2) ADD DROPDOWN:
                            //FOLDERCELL WILL CONTAIN A TABLEVIEW/COLLECTIONVIEW (INITIALLY 0PX TALL) WHICH WHEN THE DROPDOWN BUTTON IS PRESSED, WILL EXPAND
                            //TO TABLES FULL CONTENT SIZE.  CALL self.beginUpdates/endUpdates ON USER PROFILE TABLEVIEW TO RESIZE IT.
                    
                    
                    

                }else{
                    Path.initialIndexPath = nil
                    CellBeingMoved.cellSnapshot!.removeFromSuperview()
                    CellBeingMoved.cellSnapshot = nil
                    tableView.reloadData()
                }
                
                
            }
        }
    }
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseableCell", for: indexPath) as! Cell
        cell.teamLabel.text = itemsArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (finishedMovingItem) {
            return 44
        }else{
            if indexPath == lastInitialIndexPath {
                return 0
            }else{
                return 44
            }
        }

    }
}

