//
//  CalendarPopUpViewController.swift
//  Food For All
//
//  Created by Daniel Jones on 3/2/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit
import STPopup
import EZSwiftExtensions
import ActionSheetPicker_3_0

class CalendarPopUpViewController: UIViewController {
    enum DateType: Int {
        case start
        case end
    }
    
    var theDayLabel: UILabel!
    
    var start: Date?
    var end: Date?
    
    init(start: Date, end: Date) {
        super.init(nibName: nil, bundle: nil)
        self.start = start
        self.end = end
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        setContent()
        self.contentSizeInPopup = CGSize(width: ez.screenWidth, height: ez.screenHeight * 0.25)
    }
    
    func viewSetup() {
        print("override in subclasses")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setContent() {
        theDayLabel.text = start?.toString(format: "EEE, MMM d")
    }
    
    func choseNew(date: Date, sender: UIButton) {
        print("override in subclasses")
    }
}

//time extension
extension CalendarPopUpViewController {
    func timePressed(sender: UIButton) {
        if let type = DateType(rawValue: sender.tag) {
            let initialDate = type == .start ? start : end
            let datePicker = ActionSheetDatePicker(title: "Time", datePickerMode: .time, selectedDate: initialDate, doneBlock: {
                picker, value, index in
                if let date = value as? Date {
                    self.choseNew(date: date, sender: sender)
                }
            }, cancel: {_ in
                return
            }, origin: sender)
            datePicker?.minuteInterval = 15
            datePicker?.show()
        }
    }
    
    func setTitleFor(button: UIButton, date: Date?) {
        button.setTitle(date?.timeString(in: .short), for: .normal)
    }
}
