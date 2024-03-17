//
//  NSView+.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

import AppKit

extension NSView {    
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
        window?.convertToScreen(frameInWindow)
    }

    static var currentContext: CGContext? {
        NSGraphicsContext.current?.cgContext
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

    func firstSuperview<V: NSView>(for _: V.Type) -> V? {
        firstSuperview(where: { $0 is V }) as? V
    }

    func firstSuperview(where predicate: (NSView) -> (Bool)) -> NSView? {
        if let superview = superview {
            if predicate(superview) == true {
                return superview
            }
            return superview.firstSuperview(where: predicate)
        }
        return nil
    }

    @discardableResult
    func addSubview(withConstraint view: NSView) -> [NSLayoutConstraint] {
        addSubview(view)
        return view.constraint(to: self)
    }

    func insertSubview(_ view: NSView, at index: Int) {
        guard index < self.subviews.count else { return }
        var subviews = subviews
        subviews.insert(view, at: index)
        self.subviews = subviews
    }

    @discardableResult
    func constraint(to view: NSView) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let left: NSLayoutConstraint = .init(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint = .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let width: NSLayoutConstraint = .init(item: self, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        let height: NSLayoutConstraint = .init(item: self, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let constraints = [left, bottom, width, height]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}
