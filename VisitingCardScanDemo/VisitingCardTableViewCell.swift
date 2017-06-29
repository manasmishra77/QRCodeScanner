//
//  VisitingCardTableViewCell.swift
//  VisitingCardScanDemo
//
//  Created by Manas Mishra on 29/06/17.
//  Copyright © 2017 Manas Mishra. All rights reserved.
//

import UIKit

class VisitingCardTableViewCell: UITableViewCell {

    @IBOutlet weak var at: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var designation: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
