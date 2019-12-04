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

    @IBOutlet weak var titletext: UITextField!
    @IBOutlet weak var detailtext: UITextView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        titletext.becomeFirstResponder()
        
        if let todo = todo {
            titletext.text = todo.title
            segmentedControl.selectedSegmentIndex = Int(todo.priotity)
            detailtext.text = todo.detail
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboard(notification:Notification) {
        guard let keyboardReact = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        
        bottomConstraint.constant = keyboardReact.height + 10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

    }
    
    @IBAction func SubmitBtn(_ sender: UIButton) {
        guard let title = titletext.text, !title.isEmpty else {
            return
        }

        if let todo = self.todo {
            todo.title = title
            todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
            todo.detail = detailtext.text
        } else {
            let todo = TODO(context: managedContext)
            todo.title = title
            todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
            todo.date = Date()
            todo.detail = detailtext.text
            todo.done = false
        }
        
        

        
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)")
        }
        


    }
    
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        titletext.resignFirstResponder()
    }
    
    @IBAction func CancelBtn(_ sender: UIButton) {
        dismissAndResign()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
