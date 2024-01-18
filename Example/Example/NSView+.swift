//
//  NSView+.swift
//  Example
//
//  Created by Florian Zand on 12.01.24.
//

import AppKit

extension NSView {
    var borderWidth: CGFloat {
        get { layer?.borderWidth ?? 0.0 }
        set {
            wantsLayer = true
            layer?.borderWidth = newValue
        }
    }
    
    var borderColor: NSColor? {
        get { 
            if let cgColor = layer?.borderColor {
                return NSColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }
    
    var cornerRadius: CGFloat {
        get { layer?.cornerRadius ?? 0.0 }
        set {
            wantsLayer = true
            layer?.cornerRadius = newValue
        }
    }
}
