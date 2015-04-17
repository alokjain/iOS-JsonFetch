//
//  JSONFetchTableViewCell.swift
//  iOS Programming Test
//
//  Created by Bertrand on 16/04/2015.
//  Copyright (c) 2015 Bertrand Bloc'h. All rights reserved.
//

import UIKit

class JSONFetchTableViewCell: UITableViewCell {

    @IBOutlet weak var lbImageTitle: UILabel!
    @IBOutlet weak var lbUser: UILabel!
    @IBOutlet weak var imageFromJson: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
