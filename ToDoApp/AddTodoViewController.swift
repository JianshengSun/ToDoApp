//
//  TodoViewController.swift
//  ToDoApp
//
//  Created by Jason on 2019-12-01.
//  Copyright © 2019 centennialcollege. All rights reserved.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    var todo: TODO?
    //Title and Ditail textview
    @IBOutlet weak var titletext: UITextField!
    @IBOutlet weak var detailtext: UITextView!
    //UI items
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //keyborad control
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //focus title textview when start this page
        titletext.becomeFirstResponder()
        
        //get informations when link from the tabelview(Edit funcion)
        if let todo = todo {
            titletext.text = todo.title
            segmentedControl.selectedSegmentIndex = Int(todo.priotity)
            detailtext.text = todo.detail
        }
    }
    
    //bottom button move up when keyboard comes out
    @objc func keyboard(notification:Notification) {
        guard let keyboardReact = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        //the distance bottom should comes up
        bottomConstraint.constant = keyboardReact.height + 10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

    }
    //submit button(also the update button)
    @IBAction func SubmitBtn(_ sender: UIButton) {
        guard let title = titletext.text, !title.isEmpty else {
            return
        }

        //edit update
        if let todo = self.todo {
            todo.title = title
            //for priotity buttons start from 0 (here we have 0 1 2)
            todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
            todo.detail = detailtext.text}
        //add new
        else {
            let todo = TODO(context: managedContext)
            todo.title = title
            todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
            todo.date = Date()
            todo.detail = detailtext.text
            todo.done = false}
        //save data and dismiss
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)")
        }
    }
    
    //dismiss function
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        titletext.resignFirstResponder()
    }
    
    //cancel function
    @IBAction func CancelBtn(_ sender: UIButton) {
        dismissAndResign()
    }
}
