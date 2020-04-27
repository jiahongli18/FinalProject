//
//  TableViewCell.swift
//  FinalProject
//
//  Created by Jia H Li on 4/25/20.
//  Copyright © 2020 Jiahong Li. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellPrice: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(item: Item) {
        // if it's from a url change this next line
        item.loadImage {
            self.cellImage.image = item.appImage
        }
        cellPrice.text = "$\(item.price)"
        cellTitle.text = item.name
    }

}
