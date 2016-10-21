//
//  FolderDialog.swift
//  DragNDrop
//
//  Created by Joshua O'Connor on 10/20/16.
//  Copyright © 2016 Dan Fairbanks. All rights reserved.
//

import UIKit

class FolderDialog: UIView {
    
    var confirmBlock: ((_ confirmed: Bool, _ folderName: String?) -> ())?
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var folderNameTextfield: UITextField!

    override init(frame: CGRect) {
        super.init(frame: frame)

        connectNibUI()
        
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
