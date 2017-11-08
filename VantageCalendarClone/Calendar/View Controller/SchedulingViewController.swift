//
//  SchedulingViewController.swift
//  Food For All
//
//  Created by Daniel Jones on 2/27/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit
import Timepiece
import EZSwiftExtensions

class SchedulingViewController: UIViewController {
    struct Constants {
        //add 1 to ending time, to get it to be accurate on the screen
        static let numberOfSections: Int = Constants.endingTime + 1 - Constants.startingTime + Constants.customEventSection
        
        //in army time
        static let startingTime: Int = 8
        static let endingTime: Int = 22
        
        static let customEventSection: Int = 1
        static let numberOfColumns: Int = 8 //show a week's worth
        static let borderColor: UIColor = CustomColors.BombayGray
        static let borderWidth: CGFloat = 0.3
        static let calendarGrey: UIColor = UIColor(r: 244, g: 248, b: 251)
        static let alternateCalendarGrey: UIColor = UIColor(r: 242, g: 246, b: 249)
    }
    
    var theCollectionView: UICollectionView!
    
    var dataStore: ScheduleDataStore?
    var gig: Gig!
    
    var events: [CustomEvent] = [] {
        didSet {
            if isViewLoaded {
                if let layout = theCollectionView.collectionViewLayout as? ScheduleCollectionViewLayout {
                    layout.events = events
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewSetup()
        dataStoreSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let nav = navigationController as? WelcomeNavigationController, isMovingFromParentViewController {
            //we want to reset to defaults when vc is getting popped  back to previous ViewController
            nav.resetToDefaults()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setNavBar() {
        if let nav = navigationController as? WelcomeNavigationController {
            nav.change(color: Constants.calendarGrey)
            nav.navigationBar.tintColor = UIColor.black
        }
    }
    
    func pressed(cell: UICollectionViewCell, indexPath: IndexPath) {
        if cell is EventCollectionViewCell {
            eventCellPressed(indexPath: indexPath)
        }
    }
    
    func eventCellPressed(indexPath: IndexPath) {
        print("override in subclasses")
    }
    
    func dataStoreSetup() {
        dataStore = ScheduleDataStore(delegate: self)
        if events.isEmpty {
            dataStore?.load(from: self.gig)
        } else {
            //the previous vc passed us the events, so we just want to have it update the layout according to the events we were passed.
            if let layout = theCollectionView.collectionViewLayout as? ScheduleCollectionViewLayout {
                layout.events = events
            }
        }
    }
    
    func createDateCell(indexPath: IndexPath) -> DateCollectionViewCell {
        let cell = theCollectionView.dequeueReusableCell(withReuseIdentifier: DateCollectionViewCell.identifier, for: indexPath) as! DateCollectionViewCell
        let date = getDateFrom(item: indexPath.item)
        cell.set(day: date.day, weekDay: date.weekDay, month: date.month)
        
        setAlternatingBackground(cell: cell, indexPath: indexPath)
        setAlternatingTextColor(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func dayOfWeek(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).capitalized
    }
    
    func registerCells() {
        theCollectionView.register(ScheduleCollectionViewCell.self, forCellWithReuseIdentifier: ScheduleCollectionViewCell.identifier)
        theCollectionView.register(HourUnitCollectionViewCell.self, forCellWithReuseIdentifier: HourUnitCollectionViewCell.identifier)
        theCollectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: DateCollectionViewCell.identifier)
    }
    
    func createCustomEventCell(indexPath: IndexPath) -> EventCollectionViewCell {
        print("should override this method in subclasses")
        let cell = EventCollectionViewCell()
        return cell
    }
}

extension SchedulingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionViewSetup() {
        let layout = ScheduleCollectionViewLayout()
        edgesForExtendedLayout = [] //for the top x sticky axis to be in the correct placement with a nav bar
        theCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        theCollectionView.contentInset.bottom = navigationBarHeight
        registerCells()
        theCollectionView.dataSource = self
        theCollectionView.delegate = self
        theCollectionView.backgroundColor = Constants.calendarGrey //grey color from vantage calender on App Store
        
        theCollectionView.isDirectionalLockEnabled = true
        theCollectionView.alwaysBounceVertical = true
        theCollectionView.alwaysBounceHorizontal = true
        theCollectionView.showsVerticalScrollIndicator = false
        theCollectionView.showsHorizontalScrollIndicator = false
        
        self.view.addSubview(theCollectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.numberOfSections + Constants.customEventSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Constants.numberOfSections {
            //custom event section
            return events.count
        }
        
        //calender grid items
        return Constants.numberOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let item = indexPath.item
        
        if section == collectionView.numberOfSections - 1 {
            //custom events section
            return createCustomEventCell(indexPath: indexPath)
        } else if item == 0 {
            //the sticky y axis hour unit cells
            let cell = createHourUnitCell(indexPath: indexPath, collectionView: collectionView)
            return cell
        } else if section == 0 {
            //the sticky top x axis to hold the dates
            return createDateCell(indexPath: indexPath)
        } else {
            // get a reference to our storyboard cell
            let cell = createScheduleCell(indexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            pressed(cell: cell, indexPath: indexPath)
        }
    }
}

//custom event cells
extension SchedulingViewController {
    func setTitleFor(event: CustomEvent, cell: EventCollectionViewCell) {
        let title = convertToString(event: event)
        cell.set(title: title)
    }
    
    func convertToString(event: CustomEvent) -> String {
        let format = "h:mm"
        let start = event.start.toString(format: format)
        let end = event.end.toString(format: format)
        return start + " - " + end
    }
}

//the schedule cells
extension SchedulingViewController {
    fileprivate func createScheduleCell(indexPath: IndexPath) -> ScheduleCollectionViewCell {
        let cell = theCollectionView.dequeueReusableCell(withReuseIdentifier: ScheduleCollectionViewCell.identifier, for: indexPath) as! ScheduleCollectionViewCell
        setAlternatingBackground(cell: cell, indexPath: indexPath)
        
        return cell
    }
}

//the y axis of times
extension SchedulingViewController {
    fileprivate func createHourUnitCell(indexPath: IndexPath, collectionView: UICollectionView) -> HourUnitCollectionViewCell {
        let section = indexPath.section
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourUnitCollectionViewCell.identifier, for: indexPath) as! HourUnitCollectionViewCell
        
        //add times to any cells, but the top left corner cell, the first time cell and the last time cell. Trying to copy the look of Vantage calender on the App Store
        if section > 0 && section != Constants.numberOfSections - 1 {
            let time = Constants.startingTime + section
            let timeString = convertNumToTime(num: time)
            cell.setTime(title: timeString)
        } else {
            cell.setTime(title: nil)
        }
        
        return cell
    }
    
    fileprivate func convertNumToTime(num: Int) -> String {
        var suffix: String = "Am"
        var numString: String = num.toString
        
        if num >= 12 {
            suffix = "Pm"
            if num > 12 {
                numString = (num - 12).toString
            }
        }
        
        return "\(numString) \(suffix)"
    }
}

//the top x axis of dates
extension SchedulingViewController {
    func setAlternatingTextColor(cell: DateCollectionViewCell, indexPath: IndexPath) {
        if indexPath.row - 1 == 0 {
            //current day column
            cell.textColor = CustomColors.JellyTeal
        } else {
            cell.textColor = UIColor.black
        }
    }
    
    fileprivate func setAlternatingBackground(cell: UICollectionViewCell, indexPath: IndexPath) {
        if indexPath.item % 2 == 0 {
            cell.backgroundColor = Constants.calendarGrey
        } else {
            cell.backgroundColor = Constants.alternateCalendarGrey
        }
    }
    
    fileprivate func getDateFrom(item: Int) -> (day: Int, weekDay: String, month: String) {
        let date = (Date() + (item - 1).day) ?? Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let month = components.month ?? 0
        let day = components.day ?? 0
        
        let weekDayString: String = dayOfWeek(date: date)
        let monthName: String = DateFormatter().monthSymbols[month - 1]
        return (day, weekDayString, monthName)
    }
}

extension SchedulingViewController: ScheduleDataStoreDelegate {
    func loaded(events: [CustomEvent]) {
        self.events = events
        theCollectionView.reloadSections([theCollectionView.numberOfSections - 1])
    }
}


