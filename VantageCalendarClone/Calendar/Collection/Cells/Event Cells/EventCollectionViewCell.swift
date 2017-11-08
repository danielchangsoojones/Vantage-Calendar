//
//  EventCollectionViewCell.swift
//  Food For All
//
//  Created by Daniel Jones on 3/1/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    struct Constants {
        static let inset: CGFloat = 5
    }
    
    override var reuseIdentifier: String? {
        return EventCollectionViewCell.identifier
    }
    
    var theLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(r: 49, g: 62, b: 70)
        setCornerRadius(radius: 5)
        labelSetup()
        leftBorderSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(title: String) {
        theLabel.text = title
    }
    
    fileprivate func labelSetup() {
        theLabel = UILabel()
        theLabel.textColor = UIColor.white
        theLabel.font = UIFont.systemFont(ofSize: 12, weight: DateCollectionViewCell.Constants.fontWeight)
        self.addSubview(theLabel)
        theLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(Constants.inset)
            make.top.equalToSuperview().inset(Constants.inset)
        }
    }
    
    fileprivate func leftBorderSetup() {
        let line = Helpers.line
        line.alpha = 1
        line.backgroundColor = CustomColors.JellyTeal
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(2)
        }
    }
}

extension EventCollectionViewCell {
    static let identifier: String = "eventCollectionCell"
}
