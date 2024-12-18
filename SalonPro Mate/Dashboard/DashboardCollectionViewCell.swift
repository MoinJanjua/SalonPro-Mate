//
//  DashboardCollectionViewCell.swift
//  SalonPro Mate
//
//  Created by Unique Consulting Firm on 16/12/2024.
//

import UIKit

class DashboardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var images: UIImageView!
    @IBOutlet weak var bgview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //     viewShadow(view: curveView)
        
        // Set up shadow properties
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4.0
        layer.masksToBounds = false
        
        // Set background opacity
        contentView.alpha = 1.5 // Adjust opacity as needed
        
        
    }
}

