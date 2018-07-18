//
//  Post_TableViewCell.swift
//  hnmobiletest
//
//  Created by Adam Teale on 17/7/18.
//  Copyright © 2018 adam. All rights reserved.
//

import UIKit

class Post_TableViewCell: UITableViewCell {

    
    @IBOutlet var title_label: UILabel!
    @IBOutlet var authorAndTime_label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
