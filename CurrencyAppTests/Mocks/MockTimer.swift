//
//  MockTimer.swift
//  CurrencyAppTests
//
//  Created by YK Poh on 18/06/2022.
//

import Foundation

class MockTimer: Timer {
    
    var selector: Selector!
    var target: AnyObject!
    
    static var currentTimer: MockTimer!

    override func fire() {
        _ = target.perform(selector)
    }
    
    override class func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> Timer {
        let mockTimer = MockTimer()
        
        mockTimer.target = aTarget as AnyObject
        mockTimer.selector = aSelector
        
        MockTimer.currentTimer = mockTimer
        
        return mockTimer
    }
    
    override func invalidate() {
        selector = nil
        target = nil
    }
    
    static func clear() {
        currentTimer = nil
    }
}
