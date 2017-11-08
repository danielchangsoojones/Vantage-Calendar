//
//  ScheduleCollectionViewLayout.swift
//  Food For All
//
//  Created by Daniel Jones on 2/27/17.
//  Copyright © 2017 Chong500Productions. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class ScheduleCollectionViewLayout: UICollectionViewLayout {
    struct Constants {
        static let cellHeight: Double = 45.0
        static let eventCellInset: CGFloat = 1
    }
    
    let CELL_HEIGHT: Double = Constants.cellHeight
    var CELL_WIDTH: Double = 0
    var yAxisCellWidth: Double {
        return CELL_WIDTH / 2
    }
    
    var cellAttrsDictionary = Dictionary<IndexPath, UICollectionViewLayoutAttributes>()
    var contentSize = CGSize.zero
    var events: [CustomEvent] = [] {
        didSet {
            let numOfEventsChanged = events.count - oldValue.count
            if numOfEventsChanged > 0 {
                addEventCellAttributes(numOfEventsToAdd: numOfEventsChanged)
            }
        }
    }
    
    // Used to determine if a data source update has occured.
    // Note: The data source would be responsible for updating
    // this value if an update was performed.
    var dataSourceDidUpdate = true
    
    override init() {
        super.init()
        CELL_WIDTH = Double(ez.screenWidth / 3.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        // Only update header cells.
        if !dataSourceDidUpdate {
            
            // Determine current content offsets.
            let xOffset = collectionView!.contentOffset.x
            let yOffset = collectionView!.contentOffset.y
            
            if collectionView!.numberOfSections > 0 {
                //subtracting one because the final custom event section is not calculated with this. Its cells get placed above the current grid.
                for section in 0..<collectionView!.numberOfSections-1 {
                    
                    // Confirm the section has items.
                    if collectionView!.numberOfItems(inSection: section) > 0 {
                        
                        // Update all items in the first row.
                        if section == 0 {
                            for item in 0...collectionView!.numberOfItems(inSection: section)-1 {
                                
                                // Build indexPath to get attributes from dictionary.
                                let indexPath = IndexPath(item: item, section: section)
                                
                                // Update y-position to follow user.
                                if let attrs = cellAttrsDictionary[indexPath] {
                                    var frame = attrs.frame
                                    
                                    // Also update x-position for corner cell.
                                    if item == 0 {
                                        frame.origin.x = xOffset
                                    }
                                    
                                    
                                    frame.origin.y = yOffset
                                    attrs.frame = frame
                                }
                                
                            }
                            
                            // For all other sections, we only need to update
                            // the x-position for the fist item.
                        } else {
                            
                            // Build indexPath to get attributes from dictionary.
                            let indexPath = IndexPath(item: 0, section: section)
                            
                            // Update y-position to follow user.
                            if let attrs = cellAttrsDictionary[indexPath] {
                                var frame = attrs.frame
                                frame.origin.x = xOffset
                                attrs.frame = frame
                            }
                            
                        }
                    }
                }
            }
            
            
            // Do not run attribute generation code
            // unless data source has been updated.
            return
        }
        
        // Acknowledge data source change, and disable for next time.
        dataSourceDidUpdate = false
        
        
        // Cycle through each section of the data source.
        if collectionView!.numberOfSections > 0 {
            for section in 0...collectionView!.numberOfSections-1 {
                // Cycle through each item in the section.
                if collectionView!.numberOfItems(inSection: section) > 0 {
                    for item in 0...collectionView!.numberOfItems(inSection: section)-1 {
                        setCellAttributes(item: item, section: section)
                    }
                }
            }
        }
        
        // Update content size.
        let contentWidth = Double(collectionView!.numberOfItems(inSection: 0) - 1) * CELL_WIDTH + yAxisCellWidth
        //sections - 1 because the custom event cells are not factored into the height, they go on top of the current grid system
        let contentHeight = Double(collectionView!.numberOfSections - 1) * CELL_HEIGHT
        self.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    fileprivate func setCellAttributes(item: Int, section: Int) {
        // Build the UICollectionVieLayoutAttributes for the cell.
        let cellIndex = IndexPath(item: item, section: section)
        var cellWidth: Double = CELL_WIDTH
        var cellHeight: Double = CELL_HEIGHT
        var xPos: Double = 0
        var yPos = Double(section) * CELL_HEIGHT
        
        if section == collectionView!.numberOfSections - 1 {
            //custom event items
            let rect = getCustomEventRect(item: item)
            xPos = Double(rect.x)
            yPos = Double(rect.y)
            cellHeight = Double(rect.height)
            cellWidth = Double(rect.width)
        } else if item == 0 {
            //the y axis cells
            cellWidth = yAxisCellWidth
        } else {
            //all other cells
            xPos = calculateXPos(item: item)
        }
        
        let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndex)
        cellAttributes.frame = CGRect(x: xPos, y: yPos, width: cellWidth, height: cellHeight)
        
        // Determine zIndex based on cell type.
        if section == 0 && item == 0 {
            //top left corner cell
            cellAttributes.zIndex = 5
        } else if section == 0 {
            //y axis cells
            cellAttributes.zIndex = 4
        } else if section == collectionView!.numberOfSections - 1 {
            //custom event cells
            cellAttributes.zIndex = 2
        } else if item == 0 {
            //top x axis cells
            cellAttributes.zIndex = 3
        }  else {
            //all background schedule cells
            cellAttributes.zIndex = 1
        }
        
        // Save the attributes.
        cellAttrsDictionary[cellIndex] = cellAttributes
    }
    
    fileprivate func calculateXPos(item: Int) -> Double {
        return Double(item) * CELL_WIDTH - yAxisCellWidth
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = cellAttrsDictionary[indexPath]
        return attribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Create an array to hold all elements found in our current view.
        var attributesInRect = [UICollectionViewLayoutAttributes]()
        
        // Check each element to see if it should be returned.
        for cellAttributes in cellAttrsDictionary.values {
            if rect.intersects(cellAttributes.frame) {
                attributesInRect.append(cellAttributes)
            }
        }
        
        // Return list of elements.
        return attributesInRect
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

extension ScheduleCollectionViewLayout {
    func updateEventCell(at indexPath: IndexPath) {
        setCellAttributes(item: indexPath.item, section: indexPath.section)
    }
    
    func removeEventCell(at indexPath: IndexPath) {
        let eventSection: Int = collectionView!.numberOfSections - 1
        let totalEventItems: Int = collectionView!.numberOfItems(inSection: eventSection)
        
        //decrementing all indexPaths above the deleted event cell, so the attribute dictionary will be up to date, when reloadSections is run by the collectionView.
        for item in 0..<totalEventItems where item > indexPath.item {
            let targetIndexPath = IndexPath(item: item - 1, section: eventSection)
            let cellAttr = cellAttrsDictionary[IndexPath(item: item, section: eventSection)]
            cellAttr?.indexPath = targetIndexPath
            cellAttrsDictionary[targetIndexPath] = cellAttr
        }
        
        let lastIndexPath = IndexPath(item: totalEventItems - 1, section: eventSection)
        cellAttrsDictionary.removeValue(forKey: lastIndexPath)
    }
    
    fileprivate func addEventCellAttributes(numOfEventsToAdd: Int) {
        for num in 1...numOfEventsToAdd {
            setCellAttributes(item: events.count - num, section: collectionView!.numberOfSections - 1)
        }
    }
    
    fileprivate func getCustomEventRect(item: Int) -> CGRect {
        if !events.isEmpty {
            let event = events[item]
            let xPos = getEventPosX(event: event)
            let yPos = getEventPosY(event: event)
            let height = getEventHeight(event: event)
            let rect = CGRect(x: xPos, y: yPos, width: CELL_WIDTH, height: height)
            //inset a tiny bit, so not jammed against the calender edges
            return rect.insetBy(dx: Constants.eventCellInset, dy: Constants.eventCellInset)
        }
        return CGRect.zero
    }
    
    fileprivate func getEventPosX(event: CustomEvent) -> Double {
        let currentStartOfDay: Date = Date().changed(hour: 0, minute: 0, second: 0, nanosecond: 0) ?? Date()
        //using remainder 7 because we want users to input their dates, but then we want it to reoccur every week. So, people can input their schedule once, and it will continue into eternity.
        let dayDifference: Int = Int(currentStartOfDay.daysInBetweenDate(event.start)) % 7
        //+1 because the items in the grid are 1 item over because the first item is the yaxis
        let xPos = calculateXPos(item: dayDifference + 1)
        return xPos
    }
    
    fileprivate func getEventPosY(event: CustomEvent) -> Double {
        let minuteHeight: Double = CELL_HEIGHT / 60
        let xAxisHeight: Double = CELL_HEIGHT
        let minutes = event.start.hour * 60 + event.start.minute - (SchedulingViewController.Constants.startingTime * 60)
        return minuteHeight * Double(minutes) + xAxisHeight
    }
    
    fileprivate func getEventHeight(event: CustomEvent) -> Double {
        let minuteHeight: Double = CELL_HEIGHT / 60
        let minuteDifference = event.start.minutesInBetweenDate(event.end)
        return minuteDifference * minuteHeight
    }
}
