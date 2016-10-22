//
//  FolderDialog.swift
//  DragNDrop
//
//  Created by Joshua O'Connor on 10/20/16.
//  Copyright © 2016 Dan Fairbanks. All rights reserved.
//

import UIKit

class FolderDialog: UIView {
    
    var isCreateFolderMode: Bool?
    var confirmBlock: ((_ confirmed: Bool, _ folderName: String?) -> ())?
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var folderNameTextfield: UITextField!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var addCellToFolderLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    init(createFolderMode: Bool, frame: CGRect) {
        super.init(frame: frame)
        isCreateFolderMode = createFolderMode
        
        connectNibUI()
        
        setUpUI()
        
        cancelButton.layer.borderWidth = 1.5
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.cornerRadius = 3.0
        
        saveButton.layer.borderWidth = 1.5
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.cornerRadius = 3.0
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func connectNibUI() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: nil).instantiate(withOwner: self, options: nil)
        let nibView = nib.first as! UIView
        //nibView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(nibView)
    }
    
    func setUpUI() {
        if isCreateFolderMode == true {
            addCellToFolderLabel.isHidden = true
        }else{
            folderNameLabel.isHidden = true
            folderNameTextfield.isHidden = true
            saveButton.setTitle("Yes", for: .normal)
            titleLabel.text = "Add to folder?"
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        if folderNameTextfield.text != "" {
            confirmBlock?(true, folderNameTextfield.text!)
            
        }else{
            confirmBlock?(true, nil)
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        confirmBlock?(false, nil)
    }
    
    

}
