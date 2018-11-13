//
//  FirstViewController.swift
//  SimplestHealthTracker
//
//  Created by Chris on 24/10/2018.
//  Copyright © 2018 CGL. All rights reserved.
//

import UIKit
import DatePickerDialog
import CoreData

class DataEntryViewController: UIViewController {

    @IBOutlet weak var txtEntryDateTime: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtCircumferance: UITextField!
    @IBOutlet weak var txtFatPercent: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    
    private var entryDateTime:Date?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.btnUpdate.addTarget(self, action: #selector(btnUpdateClick), for: .touchUpInside)
        self.txtEntryDateTime.delegate = self
        self.btnUpdate.isEnabled = false
        
        self.checkTokenAndLoginIfNoToken(callbackAfterLogin: { x in
            self.btnUpdate.isEnabled = true
        })
        
    }
    
    @objc func btnUpdateClick(_ sender: Any!) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newEntry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context)
        
        newEntry.setValue( Int(self.txtCircumferance.text!), forKey:"circumferenceCm")
        newEntry.setValue( Int(self.txtFatPercent.text!), forKey: "fatPercentage")
        newEntry.setValue( Int(self.txtWeight.text!), forKey: "weightKg")
        newEntry.setValue( SessionManager.instance.profile?.name, forKey: "username")
        newEntry.setValue( self.entryDateTime, forKey: "EntryDateTime")
        
    }
    
    func datePickerTapped() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: .black,
                                          buttonColor: .blue,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        
        
        datePicker.show("Select Entry Date/Time",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: threeMonthAgo,
                        maximumDate: currentDate,
                        datePickerMode: .dateAndTime) { (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "dd/MM/yyyy HH:mm"
                                self.txtEntryDateTime.text = formatter.string(from: dt)
                                self.entryDateTime = dt
                            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension DataEntryViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtEntryDateTime {
            datePickerTapped()
            return false
        }
        
        return true
    }
}


