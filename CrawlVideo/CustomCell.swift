//
//  CustomCell.swift
//  CrawlVideo
//
//  Created by admin on 12/14/16.
//  Copyright © 2016 TuNguyen. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var imageSong: UIImageView!
    @IBOutlet weak var nameSong: UILabel!
    @IBOutlet weak var artistSong: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var constrainLabel: NSLayoutConstraint!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
