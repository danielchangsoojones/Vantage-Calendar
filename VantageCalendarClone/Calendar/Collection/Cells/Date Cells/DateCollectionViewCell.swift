//
//  DateCollectionViewCell.swift
//  Food For All
//
//  Created by Daniel Jones on 2/28/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    struct Constants {
        static let fontWeight: CGFloat = UIFontWeightBold
    }
    
    var theDayLabel: UILabel!
    var theWeekDayLabel: UILabel!
    var theMonthLabel: UILabel!
    
    var textColor: UIColor = UIColor.black {
        didSet {
            theDayLabel.textColor = textColor
            theWeekDayLabel.textColor = textColor
            theMonthLabel.textColor = textColor
        }
    }
    
    var sideOffset: CGFloat {
        return self.frame.width * 0.1
    }
    
    override var reuseIdentifier: String? {
        return DateCollectionViewCell.identifier
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBorder(width: SchedulingViewController.Constants.borderWidth, color: SchedulingViewController.Constants.borderColor)
        dayLabelSetup()
        weekDayLabelSetup()
        monthLabelSetup()
        textColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(day: Int, weekDay: String, month: String) {
        theDayLabel.text = day.toString
        theWeekDayLabel.text = weekDay
        theMonthLabel.text = month
    }
    
    fileprivate func dayLabelSetup() {
        theDayLabel = UILabel()
        theDayLabel.font = UIFont.systemFont(ofSize: 25, weight: Constants.fontWeight)
        self.addSubview(theDayLabel)
        theDayLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(sideOffset)
        }
    }
    
    fileprivate func weekDayLabelSetup() {
        theWeekDayLabel = UILabel()
        theWeekDayLabel.font = UIFont.systemFont(ofSize: 10, weight: Constants.fontWeight)
        self.addSubview(theWeekDayLabel)
        theWeekDayLabel.snp.makeConstraints { (make) in
            make.top.equalTo(theDayLabel).offset(3)
            make.trailing.equalToSuperview().inset(sideOffset)
        }
    }
    
    fileprivate func monthLabelSetup() {
        theMonthLabel = UILabel()
        theMonthLabel.font = UIFont.systemFont(ofSize: 10, weight: Constants.fontWeight)
        self.addSubview(theMonthLabel)
        theMonthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(theWeekDayLabel.snp.bottom)
            make.trailing.equalTo(theWeekDayLabel)
        }
    }
}

extension DateCollectionViewCell {
    static let identifier: String = "dateCollectionViewCell"
}
