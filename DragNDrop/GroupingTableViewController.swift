//
//  GroupingTableViewController.swift
//  DragNDrop
//
//  Created by Josh O'Connor on 10/20/16.
//  Copyright (c) 2016 Josh O'Connor. All rights reserved.
//

import UIKit

class GroupingTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var teamDictionary: [Int : String] = [:]
    var foldersList: [String : [String]] = [:]  //this will be [folderId: [teams]].  In our project it will be [folderID: [Media]]
    var itemsArray : NSMutableArray
    var finishedMovingItem: Bool = true
    var cellBeingMoved: Cell?
    var previousHighlightedCell: Cell?
    var expandedIndexPath: Int?
    var aCellIsExpanded: Bool = false
    var tappedIndex: Int?
    fileprivate var lastInitialIndexPath : IndexPath? = nil
    @IBOutlet weak var mainTableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        itemsArray = NSMutableArray()
        
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
        
        itemsArray.add(item1)
        itemsArray.add(item2)
        itemsArray.add(item3)
        itemsArray.add(item4)
        itemsArray.add(item5)
        itemsArray.add(item6)
        itemsArray.add(item7)
        itemsArray.add(item8)
        itemsArray.add(item9)
        itemsArray.add(item10)
        
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<itemsArray.count {
            if teamDictionary[i] == nil {
                teamDictionary[i] = String(describing: itemsArray[i])
            }
        }
        print(teamDictionary)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        self.mainTableView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "FolderCell")// CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        self.mainTableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "ReuseableCell")// CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        
        mainTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(GroupingTableViewController.longPressGestureRecognized(_:)))
        mainTableView.addGestureRecognizer(longpress)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: mainTableView)
        let indexPath = mainTableView.indexPathForRow(at: locationInView)
        
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
                let cell = mainTableView.cellForRow(at: indexPath!) as? Cell
                
                CellBeingMoved.cellSnapshot = snapshotOfCell(cell!)
                var center = cell?.center
                CellBeingMoved.cellSnapshot!.center = center!
                CellBeingMoved.cellSnapshot!.alpha = 0.0
                mainTableView.addSubview(CellBeingMoved.cellSnapshot!)
                
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
                    let cell = mainTableView.cellForRow(at: indexPath!) as? Cell
                    cell?.backgroundColor = UIColor.lightGray
                    previousHighlightedCell = cell
                    self.mainTableView.reloadRows(at: [Path.initialIndexPath!], with: .automatic)
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
                    confirmFollowingAlertView.center.x = self.mainTableView.center.x
                    confirmFollowingAlertView.center.y = self.mainTableView.center.y - 45
                    confirmFollowingAlertView.confirmBlock = { confirmed, folderName in

                        
                        if confirmed == true && folderName != nil {
                            if let folderName = folderName {
                                print("CREATING FOLDER: \(folderName)")
                                print("            cellBeingMoved-> \(self.cellBeingMoved?.teamLabel.text)")
                                print("            previousHighlightedCell-> \(self.previousHighlightedCell?.teamLabel.text)")
                                
                                confirmFollowingAlertView.removeFromSuperview()
                                
                                if (self.foldersList[folderName] == nil) {
                                    self.foldersList[folderName] = [self.cellBeingMoved!.teamLabel.text!, self.previousHighlightedCell!.teamLabel.text!]
                                    print("Folders list:\(self.foldersList)")
                                    
                                    if let teamBeingMoved = self.cellBeingMoved?.teamLabel.text, let teamSelected = self.previousHighlightedCell?.teamLabel.text {
                                        
                                        self.itemsArray.insert("Folder: \(teamBeingMoved), \(teamSelected)", at: self.mainTableView.indexPath(for: self.previousHighlightedCell!)!.row)
                                        self.itemsArray.remove(teamBeingMoved)
                                        self.itemsArray.remove(teamSelected)

                                        
                                        
                                    }
                                    self.mainTableView.reloadData()
                                    Path.initialIndexPath = indexPath
                                    
                                    let cell = self.mainTableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
                                    
                                    
                                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                        if let cell = cell{
                                            CellBeingMoved.cellSnapshot!.center = cell.center
                                        }
                                        
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
                            self.mainTableView.reloadData()
                        }
                        
                    }
                    

                    //TO DO:  
                        //1) ABILITY TO ADD TEAMS TO EXISTING FOLDERS  
                            //DRAG AND HOLD TEAM CELLS, DROP INTO FOLDER, ALERT SHOWS UP
                                //DO YOU WANT TO ADD THIS TEAM TO THE FOLDER?
                        //2) ABILITY TO REMOVE TEAMS FROM FOLDERS
                            //DRAG AND HOLD CELL IN FOLDER TO REMOVE THEM
                        //3) ABILITY TO MOVE FOLDERS
                    
                    
                    

                }else{
                    Path.initialIndexPath = nil
                    CellBeingMoved.cellSnapshot!.removeFromSuperview()
                    CellBeingMoved.cellSnapshot = nil
                    mainTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cv = tableView as? IndexedTableView {
            return 2
        }else{
            return itemsArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cv = tableView as? IndexedTableView {
            let indexedFolderName = cv.indexedFolderName
            let cell = UITableViewCell()

            for item in foldersList {
                let folderName = item.0
                if folderName == indexedFolderName {
                    let teams = item.1
                    cell.textLabel?.text = "    " + teams[indexPath.row]
                    cell.textLabel?.textColor = UIColor.blue
                }
            }

            return cell

        }else{
            
            if ((itemsArray[(indexPath as NSIndexPath).row] as AnyObject).hasPrefix("Folder:")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell
                
                for item in foldersList {
                    let teams = item.1
                    for team in teams {
                        if ((itemsArray[(indexPath as NSIndexPath).row] as? String)?.contains(team))! {
                            cell.folderName.text = item.0
                            cell.foldersName = item.0
                            cell.contents = item.1
                        }
                    }
                    
                }
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseableCell", for: indexPath) as! Cell
                cell.teamLabel.text = String(describing: itemsArray[(indexPath as NSIndexPath).row])
                return cell
                
            }

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = tableView.cellForRow(at: indexPath)

        tappedIndex = indexPath.row
        switch selectedCell {
            case let teamCell as Cell:
                print("do nothing!")
                mainTableView.reloadData()
            case let folderCell as FolderCell:
                print("Expand cell!")
                if (expandedIndexPath == nil){
                    expandedIndexPath = indexPath.row
                }else{
                    if expandedIndexPath == tappedIndex {
                        expandedIndexPath = nil
                        folderCell.tableView.frame = CGRect(x: 0, y: 45, width: 406, height: 0)
                    }else{
                        expandedIndexPath = tappedIndex
                        folderCell.tableView.frame = CGRect(x: 0, y: 45, width: 406, height: 100)
                    }
                    
                }
                
                
                folderCell.tableView.dataSource = self
                folderCell.tableView.delegate = self
                folderCell.tableView.indexedFolderName = folderCell.foldersName
                folderCell.tableView.reloadData()
                
                mainTableView.beginUpdates()
                mainTableView.endUpdates()
            
            default:
                break
            
        }
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cv = tableView as? IndexedTableView {
            return 44
        }else{
            if let expandedIndexPath = expandedIndexPath {
                if expandedIndexPath == indexPath.row {
                    aCellIsExpanded = true
                    return 132
                }else{
                    return 44
                }
            }
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
    
}

