//
//  CourseListCell.swift
//  UBCExplorerIO
//
//  Created by Nucha Powanusorn on 22/7/20.
//  Copyright © 2020 Nucha Powanusorn. All rights reserved.
//

import UIKit

class CourseListCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
