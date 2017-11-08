//
//  CalendarPopUpView.swift
//  Food For All
//
//  Created by Daniel Jones on 3/2/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class CalendarPopUpView: UIView {
    struct Constants {
        static let font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        static let textColor: UIColor = UIColor.black
        static let verticalSpacing: CGFloat = 13
    }
    
    var theDayLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dayLabelSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func dayLabelSetup() {
        theDayLabel = UILabel()
        theDayLabel.font = Constants.font
        self.addSubview(theDayLabel)
        theDayLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(Constants.verticalSpacing)
        }
    }
}
