//
//  File.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

import AppKit

internal extension NSView {
    /**
     The frame rectangle, which describes the view’s location and size in its window’s coordinate system.

     This rectangle defines the size and position of the view in its window’s coordinate system. If the view isn't installed in a window, it will return zero.
     */
    var frameInWindow: CGRect {
        convert(bounds, to: nil)
    }

    /**
     The frame rectangle, which describes the view’s location and size in its screen’s coordinate system.

     This rectangle defines the size and position of the view in its screen’s coordinate system.
     */
    var frameOnScreen: CGRect? {
        return window?.convertToScreen(frameInWindow)
    }
    
    static var currentContext: CGContext? {
        return NSGraphicsContext.current?.cgContext
    }

    var renderedImage: NSImage {
        let image = NSImage(size: bounds.size)
        image.lockFocus()

        if let context = Self.currentContext {
            layer?.render(in: context)
        }

        image.unlockFocus()
        return image
    }
}
