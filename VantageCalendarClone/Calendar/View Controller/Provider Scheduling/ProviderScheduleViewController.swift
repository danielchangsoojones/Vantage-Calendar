//
//  ProviderScheduleViewController.swift
//  Food For All
//
//  Created by Daniel Jones on 3/4/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit
import Timepiece
import STPopup

class ProviderScheduleViewController: SchedulingViewController {
    var providerDataStore: ProviderScheduleDataStore?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func pressed(cell: UICollectionViewCell, indexPath: IndexPath) {
        super.pressed(cell: cell, indexPath: indexPath)
        if cell is ScheduleCollectionViewCell {
            scheduleCellPressed(indexPath: indexPath)
        }
    }
    
    override func eventCellPressed(indexPath: IndexPath) {
        let event = events[indexPath.row]
        let popUpVC = ProviderPopUpViewController(start: event.start, end: event.end, delegate: self)
        let popUpController = STPopupController(rootViewController: popUpVC)
        popUpController.style = .bottomSheet
        popUpController.present(in: self)
    }
    
    override func dataStoreSetup() {
        super.dataStoreSetup()
        providerDataStore = ProviderScheduleDataStore()
    }
    
    override func createDateCell(indexPath: IndexPath) -> DateCollectionViewCell {
        let cell = super.createDateCell(indexPath: indexPath)
        cell.theWeekDayLabel.font = cell.theWeekDayLabel.font.withSize(15)
        cell.theDayLabel.isHidden = true
        cell.theMonthLabel.isHidden = true
        return cell
    }
    
    override func dayOfWeek(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    override func registerCells() {
        super.registerCells()
        theCollectionView.register(EditableEventCollectionViewCell.self, forCellWithReuseIdentifier: EditableEventCollectionViewCell.editIdentifier)
    }
    
    override func createCustomEventCell(indexPath: IndexPath) -> EventCollectionViewCell {
        let cell = theCollectionView.dequeueReusableCell(withReuseIdentifier: EditableEventCollectionViewCell.editIdentifier, for: indexPath) as! EditableEventCollectionViewCell
        setPanAttributes(pan: cell.theUpPan)
        setPanAttributes(pan: cell.theDownPan)
        cell.addLongPressGesture(target: self, action: #selector(eventCellLongPressed(longPress:)))
        let event = events[indexPath.item]
        if event.isNew {
            event.isNew = false
            cell.toggleHandles(hide: false, duration: 0)
        } else {
            setTitleFor(event: events[indexPath.item], cell: cell)
        }
        return cell
    }
}

extension ProviderScheduleViewController {
    fileprivate func scheduleCellPressed(indexPath: IndexPath) {
        let selectedHour = indexPath.section - 1 + Constants.startingTime//accounting for the top x axis as section 0
        //acounting for the left y axis as item 0
        if let selectedDate: Date = Date() + (indexPath.row - 1).day {
            let startDate = Date(year: selectedDate.year, month: selectedDate.month, day: selectedDate.day, hour: selectedHour, minute: 0, second: 0, nanosecond: 0)
            let endDate: Date = (startDate + 1.hour) ?? startDate
            let event = CustomEvent(start: startDate, end: endDate)
            event.isNew = true
            events.append(event)
            save(event: event)
        }
    }
    
    fileprivate func save(event: CustomEvent) {
        providerDataStore?.save(event: event)
        //Can not use collectionView.reloadSections here or else it will produce random crashes, getting mad about layoutAttributes IndexPath. I (Daniel Jones) have no idea why reloadData works instead, but it does.
        theCollectionView.reloadData()
        if let newCell = theCollectionView.cellForItem(at: IndexPath(item: events.count - 1, section: theCollectionView.numberOfSections - 1)) as? EditableEventCollectionViewCell {
           newCell.toggleHandles(hide: false)
        }
    }
}

extension ProviderScheduleViewController: UIGestureRecognizerDelegate {
    func draggingCell(pan: UIPanGestureRecognizer) {
        if let handle = pan.view, let eventCell = handle.superview {
            if pan.state == .began || pan.state == .changed {
                animateCellChange(pan: pan, handle: handle, eventCell: eventCell)
            } else if pan.state == .ended {
                endHandleDragging(eventCell: eventCell)
            }
        }
    }
    
    fileprivate func animateCellChange(pan: UIPanGestureRecognizer, handle: UIView, eventCell: UIView) {
        UIView.animate(withDuration: 0.05, animations: {
            if let orientation = DragDirection(rawValue: handle.tag) {
                let translation = pan.translation(in: self.view)
                
                switch orientation {
                case .up:
                    let targetY: Double = Double(eventCell.y + translation.y)
                    if targetY > ScheduleCollectionViewLayout.Constants.cellHeight {
                        //don't let the user drag beyond the x axis top header
                        eventCell.y += translation.y
                        eventCell.h += -translation.y
                    }
                case .down:
                    eventCell.h += translation.y
                }
                
                //the handlePan handler gets called repeatedly as the user moves their finger. By default the translation tells you how far you have moved since the touch started. Since we are using the gestureRecognizer to drag the view and we have already accounted for the translation, we set it back to zero so that the next time handlePan gets called it will report how far the touch has moved from the previous call to handlePan.
                pan.setTranslation(CGPoint.zero, in: self.view)
                
                //makes sure that all subviews of the cell update as we drag, without layoutIfNeeded, the subviews will move around while the cell is being dragged
                eventCell.layoutIfNeeded()
            }
        })
    }
    
    fileprivate func endHandleDragging(eventCell: UIView) {
        let targetMinY = self.getTarget(y: eventCell.frame.minY)
        let targetMaxY = self.getTarget(y: eventCell.frame.maxY)
        UIView.animate(withDuration: 0.5, animations: {
            let targetFrame = CGRect(x: eventCell.x, y: targetMinY, w: eventCell.w, h: targetMaxY - targetMinY).insetBy(dx: 0, dy: ScheduleCollectionViewLayout.Constants.eventCellInset)
            eventCell.frame = targetFrame
            eventCell.layoutIfNeeded()
        }, completion: { _ in
            self.updateAndSaveEvent(eventCell: eventCell, targetMinY: targetMinY, targetMaxY: targetMaxY)
            self.hideHandles(eventCell: eventCell)
        })
    }
    
    fileprivate func updateAndSaveEvent(eventCell: UIView, targetMinY: CGFloat, targetMaxY: CGFloat) {
        if let eventCell = eventCell as? UICollectionViewCell, let indexPath = self.theCollectionView.indexPath(for: eventCell)  {
            let event = events[indexPath.item]
            let startTime = self.getTimeFrom(position: targetMinY)
            let start = event.start.changed(hour: startTime.hours, minute: startTime.minutes) ?? event.start
            let endTime = self.getTimeFrom(position: targetMaxY)
            let end = event.end.changed(hour: endTime.hours, minute: endTime.minutes) ?? event.end
            updateEventUI(indexPath: indexPath, start: start, end: end)
            providerDataStore?.save(event: event)
        }
    }
    
    fileprivate func hideHandles(eventCell: UIView) {
        if let eventCell = eventCell as? EditableEventCollectionViewCell, let indexPath = self.theCollectionView.indexPath(for: eventCell) {
            self.setTitleFor(event: self.events[indexPath.item], cell: eventCell)
            eventCell.toggleHandles(hide: true)
            if let recognizers = eventCell.gestureRecognizers {
                let tap = recognizers.first(where: { (recognizer) -> Bool in
                    return recognizer is UITapGestureRecognizer
                })
                if let tap = tap {
                    eventCell.removeGestureRecognizer(tap)
                }
            }
        }
    }
    
    fileprivate func getTarget(y: CGFloat) -> CGFloat {
        let minute: CGFloat = CGFloat(ScheduleCollectionViewLayout.Constants.cellHeight / 60)
        let dragUnit: CGFloat = 15 * minute
        let surplus = y / dragUnit
        let targetY = surplus.rounded() * dragUnit
        return targetY
    }
    
    func getTimeFrom(position: CGFloat) -> (minutes: Int, hours: Int) {
        let hourUnit: CGFloat = CGFloat(ScheduleCollectionViewLayout.Constants.cellHeight)
        let minuteUnit: CGFloat = hourUnit / 60
        let hours: CGFloat = floor(position / hourUnit) + CGFloat(Constants.startingTime - 1)
        let minutes = position.truncatingRemainder(dividingBy: hourUnit) / minuteUnit
        return (Int(minutes), Int(hours))
    }
    
    fileprivate func setPanAttributes(pan: UIPanGestureRecognizer) {
        pan.addTarget(self, action: #selector(draggingCell(pan:)))
        pan.delegate = self
    }
    
    func eventCellLongPressed(longPress: UILongPressGestureRecognizer) {
        if let eventCell = longPress.view as? EditableEventCollectionViewCell, longPress.state == .began {
            eventCell.toggleHandles(hide: false)
            eventCell.addTapGesture(action: { (tap) in
                self.hideHandles(eventCell: eventCell)
            })
        }
    }
}

extension ProviderScheduleViewController: ProviderPopUpDelegate {
    func updateTime(start: Date?, end: Date?) {
        if let selectedIndexPath = theCollectionView.indexPathsForSelectedItems?.last {
            let event = events[selectedIndexPath.item]
            updateEventUI(indexPath: selectedIndexPath, start: start, end: end)
            let cell = theCollectionView.cellForItem(at: selectedIndexPath)
            cell?.isSelected = true
            save(event: event)
        }
    }
    
    fileprivate func updateEventUI(indexPath: IndexPath, start: Date?, end: Date?) {
        let event = events[indexPath.item]
        if let start = start {
            event.start = start
        }
        if let end = end {
            event.end = end
        }
        if let layout = theCollectionView.collectionViewLayout as? ScheduleCollectionViewLayout {
            layout.updateEventCell(at: indexPath)
        }
    }
    
    func deleteEvent() {
        if let selectedIndexPath = theCollectionView.indexPathsForSelectedItems?.last, let layout = theCollectionView.collectionViewLayout as? ScheduleCollectionViewLayout {
            providerDataStore?.delete(event: events[selectedIndexPath.row])
            events.remove(at: selectedIndexPath.row)
            layout.removeEventCell(at: selectedIndexPath)
            theCollectionView.reloadSections([theCollectionView.numberOfSections - 1])
        }
    }
}
