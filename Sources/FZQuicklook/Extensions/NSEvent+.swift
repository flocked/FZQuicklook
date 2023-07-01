//
//  File.swift
//  
//
//  Created by Florian Zand on 01.07.23.
//

import AppKit

internal extension NSEvent {
    /**
     The location of the event inside the specified view.
     - Parameters view: The view for the location.
     - Returns: The location of the event.
     */
    func location(in view: NSView) -> CGPoint {
        return view.convert(locationInWindow, from: nil)
    }
}
