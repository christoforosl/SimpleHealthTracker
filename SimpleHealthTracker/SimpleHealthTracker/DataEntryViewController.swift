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

class DataEntryViewController: UIViewController, UICollectionViewDataSource , UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
   
    @IBOutlet weak var txtEntryDateTime: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtCircumferance: UITextField!
    @IBOutlet weak var txtFatPercent: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    
    @IBOutlet weak var collectionEntries: UICollectionView!
    private var entryDateTime:Date?
    private let formatter = DateFormatter()
    private var data:NSArray?
    private var unib = UINib(nibName: "HeatlhEntryCollectionViewCell", bundle: nil)
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.collectionEntries.dataSource = self
        self.collectionEntries.delegate = self
        self.collectionEntries.register(self.unib, forCellWithReuseIdentifier: "HeatlhEntryCollectionViewCell")
        
        self.formatter.dateFormat = "dd/MM/yyyy HH:mm"
        self.btnUpdate.addTarget(self, action: #selector(btnUpdateClick), for: .touchUpInside)
        self.txtEntryDateTime.delegate = self
        self.btnUpdate.isEnabled = false
        self.entryDateTime = Date()
        self.txtEntryDateTime.text = formatter.string(from: self.entryDateTime!)
        
        self.checkTokenAndLoginIfNoToken(callbackAfterLogin: { x in
            self.btnUpdate.isEnabled = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthEntry")
            request.returnsObjectsAsFaults = false
            do {
                
                self.data = try context.fetch(request) as NSArray
                self.collectionEntries.reloadData()
                
                MessageBox.show("Entries Loaded:\(self.data!.count)")
            } catch {
                MessageBox.showError("There was an error fatching your data :-( ")
            }
            
            
        })
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50);
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data == nil ? 0 : self.data!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HeatlhEntryCollectionViewCell", for: indexPath) as! HeatlhEntryCollectionViewCell
        
        cell.backgroundColor = UIColor.clear
        
        if ( self.data!.count >= (indexPath.row + 1) ) {
            cell.configCell(entry: self.data![indexPath.row] as! HealthEntry, entryNo: (indexPath.row + 1))
            
        }
        
        return cell;
    }
    
    @objc func btnUpdateClick(_ sender: Any!) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newEntry = NSEntityDescription.insertNewObject(forEntityName: "HealthEntry", into: context)
        
        newEntry.setValue( Int(self.txtCircumferance.text!), forKey:"circumferenceCm")
        newEntry.setValue( Int(self.txtFatPercent.text!), forKey: "fatPercentage")
        newEntry.setValue( Int(self.txtWeight.text!), forKey: "weightKg")
        newEntry.setValue( SessionManager.instance.profile?.name, forKey: "userName")
        newEntry.setValue( self.entryDateTime, forKey: "entryDateTime")
        newEntry.setValue( nil, forKey: "synchedDateTime")
        newEntry.setValue( Date(), forKey: "createdDateTime")
        newEntry.setValue( Date(), forKey: "updatedDateTime")
        
        do {
            
            try context.save()
            MessageBox.show("Your Entry your saved ")
        } catch {
            MessageBox.showError("There was an error saving your data :-) ")
        }
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
                                self.entryDateTime = dt
                                self.txtEntryDateTime.text = self.formatter.string(from: self.entryDateTime!)
                                
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


