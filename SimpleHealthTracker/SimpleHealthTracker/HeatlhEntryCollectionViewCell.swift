//
//  HeatlhEntryCollectionViewCell.swift
//  SimpleHealthTracker
//
//  Created by Chris on 13/11/2018.
//  Copyright © 2018 CGL. All rights reserved.
//

import UIKit

class HeatlhEntryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var EntryDate: UILabel!
    @IBOutlet weak var Weight: UILabel!
    @IBOutlet weak var Circumference: UILabel!
    @IBOutlet weak var fat: UILabel!
    
    private let formatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.formatter.dateFormat = "dd/MMM/yyyy HH:mm"
        // Initialization code
    }

    public func configure(entry:HealthEntry) {
        
        self.EntryDate.text = formatter.string(from: entry.entryDateTime!)
        self.Weight.text = String( entry.weightKg )
        self.fat.text = String(entry.fatPercentage)
        self.Circumference.text = String(entry.circumferenceCm)
    }
}
