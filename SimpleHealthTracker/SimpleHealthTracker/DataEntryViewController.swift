//
//  FirstViewController.swift
//  SimplestHealthTracker
//
//  Created by Chris on 24/10/2018.
//  Copyright © 2018 CGL. All rights reserved.
//

import UIKit
import DatePickerDialog

class DataEntryViewController: UIViewController {

    @IBOutlet weak var entryDateTime: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.entryDateTime.delegate = self

        self.checkTokenAndLoginIfNoToken(callbackAfterLogin: { x in
            
        })
        
    }
    
    func datePickerTapped() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        let datePicker = DatePickerDialog(textColor: .red,
                                          buttonColor: .red,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        
        datePicker.show("DatePickerDialog",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: threeMonthAgo,
                        maximumDate: currentDate,
                        datePickerMode: .date) { (date) in
                            if let dt = date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM/dd/yyyy"
                                self.entryDateTime.text = formatter.string(from: dt)
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
        if textField == self.entryDateTime {
            datePickerTapped()
            return false
        }
        
        return true
    }
}


