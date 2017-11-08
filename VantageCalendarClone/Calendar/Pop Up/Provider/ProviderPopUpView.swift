//
//  ProviderPopUpView.swift
//  Food For All
//
//  Created by Daniel Jones on 3/4/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit

class ProviderPopUpView: CalendarPopUpView {
    var theStackView: UIStackView!
    var theStartTimeButton: UIButton!
    var theEndTimeButton: UIButton!
    var theHyphenLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func stackViewSetup() {
        hyphenLabelSetup()
        theStartTimeButton = createTimeButton(title: "start")
        theEndTimeButton = createTimeButton(title: "end")
        theStackView = UIStackView(arrangedSubviews: [theStartTimeButton, theHyphenLabel, theEndTimeButton])
        theStackView.axis = .horizontal
        theStackView.alignment = .center
        theStackView.spacing = 10
        theStackView.distribution = .equalCentering
        self.addSubview(theStackView)
        theStackView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(theDayLabel.snp.bottom).offset(10)
        }
    }
    
    fileprivate func createTimeButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitleColor(Constants.textColor, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Constants.font
        return button
    }
    
    fileprivate func hyphenLabelSetup() {
        theHyphenLabel = UILabel()
        theHyphenLabel.font = Constants.font
        theHyphenLabel.text = "-"
    }
}
