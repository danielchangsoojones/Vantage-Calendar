//
//  ProviderPopUpViewController.swift
//  Food For All
//
//  Created by Daniel Jones on 3/4/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit

protocol ProviderPopUpDelegate {
    func deleteEvent()
    func updateTime(start: Date?, end: Date?)
}

class ProviderPopUpViewController: CalendarPopUpViewController {
    var theStartTimeButton: UIButton!
    var theEndTimeButton: UIButton!
    
    var delegate:ProviderPopUpDelegate?
    
    init(start: Date, end: Date, delegate: ProviderPopUpDelegate) {
        super.init(start: start, end: end)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButtonSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewSetup() {
        let popUpView = ProviderPopUpView(frame: self.view.bounds)
        self.view = popUpView
        theDayLabel = popUpView.theDayLabel
        theStartTimeButton = popUpView.theStartTimeButton
        theEndTimeButton = popUpView.theEndTimeButton
        popUpView.theStartTimeButton.addTarget(self, action: #selector(timePressed(sender:)), for: .touchUpInside)
        popUpView.theEndTimeButton.addTarget(self, action: #selector(timePressed(sender:)), for: .touchUpInside)
    }
    
    override func setContent() {
        super.setContent()
        setTitleFor(button: theStartTimeButton, date: start)
        setTitleFor(button: theEndTimeButton, date: end)
        theStartTimeButton.tag = DateType.start.rawValue
        theEndTimeButton.tag = DateType.end.rawValue
    }
    
    override func choseNew(date: Date, sender: UIButton) {
        if sender == self.theStartTimeButton {
            if let end = self.end, end < date {
                Helpers.showBanner(title: "Invalid Time", subtitle: "You inputted a start time that occurs after the end time", bannerType: .error)
                return
            } else {
                self.picked(newStart: date)
            }
        } else if sender == self.theEndTimeButton {
            if let start = self.start, start > date {
                Helpers.showBanner(title: "Invalid Time", subtitle: "You inputted an end time that occurs before your start time", bannerType: .error)
                return
            } else {
                self.picked(newEnd: date)
            }
        }
        
        self.delegate?.updateTime(start: self.start, end: self.end)
    }
}

//nav bar extension
extension ProviderPopUpViewController {
    fileprivate func deleteButtonSetup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteEvent))
    }
    
    func deleteEvent() {
        delegate?.deleteEvent()
        self.popupController?.dismiss()
    }
}

//time extension
extension ProviderPopUpViewController {
    fileprivate func picked(newStart: Date) {
        start = newStart
        setTitleFor(button: theStartTimeButton, date: newStart)
    }
    
    fileprivate func picked(newEnd: Date) {
        end = newEnd
        setTitleFor(button: theEndTimeButton, date: newEnd)
    }
}
