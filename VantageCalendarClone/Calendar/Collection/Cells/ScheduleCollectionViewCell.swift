//
//  ScheduleCollectionViewCell.swift
//  Food For All
//
//  Created by Daniel Jones on 2/27/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    override var reuseIdentifier: String? {
        return ScheduleCollectionViewCell.identifier
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addBorder(width: SchedulingViewController.Constants.borderWidth, color: SchedulingViewController.Constants.borderColor)
    }
}

extension ScheduleCollectionViewCell {
    static let identifier: String = "scheduleCollectionCell"
}
