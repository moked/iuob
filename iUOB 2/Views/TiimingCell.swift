//
//  TiimingCell.swift
//  iUOB 2
//
//  Created by Miqdad Altaitoon on 8/13/16.
//  Copyright © 2016 Miqdad Altaitoon. All rights reserved.
//

import UIKit

class TiimingCell: UITableViewCell {

    @IBOutlet weak var sectionNoLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var dayHeaderLabel: UILabel!
    @IBOutlet weak var timeHeaderLabel: UILabel!
    @IBOutlet weak var roomHeaderLabel: UILabel!
    @IBOutlet weak var watchButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sectionNoLabel.layer.masksToBounds = true
        dayLabel.layer.masksToBounds = true
        timeLabel.layer.masksToBounds = true
        roomLabel.layer.masksToBounds = true
        
        self.sectionNoLabel.layer.cornerRadius = sectionNoLabel.frame.width / 2;
        self.dayLabel.layer.cornerRadius = 8
        self.timeLabel.layer.cornerRadius = 8
        self.roomLabel.layer.cornerRadius = 8
        
        dayHeaderLabel.layer.masksToBounds = true
        timeHeaderLabel.layer.masksToBounds = true
        roomHeaderLabel.layer.masksToBounds = true
        
        self.dayHeaderLabel.layer.cornerRadius = 8
        self.timeHeaderLabel.layer.cornerRadius = 8
        self.roomHeaderLabel.layer.cornerRadius = 8
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
