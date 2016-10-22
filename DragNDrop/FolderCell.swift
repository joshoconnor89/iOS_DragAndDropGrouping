//
//  Cell.swift
//  DragNDrop
//
//  Created by Joshua O'Connor on 10/20/16.
//  Copyright © 2016 Josh O'Connor. All rights reserved.
//

import UIKit

class FolderCell: UITableViewCell {
    
    var contents: [String]?
    var foldersName: String?
    var teams: NSMutableArray = NSMutableArray()
    

    @IBOutlet weak var tableView: IndexedTableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var folderName: UILabel!





    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib(nibName: "FolderCell", bundle: nil), forCellReuseIdentifier: "FolderCell")
        
        tableView.allowsSelection = false
        
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        

    }
    
    func populateTableView() {
        print(contents)
        
        
    }
    
}
