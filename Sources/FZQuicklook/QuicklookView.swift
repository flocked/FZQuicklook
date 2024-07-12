//
//  QuicklookView.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

import AppKit
import FZSwiftUtils
import Quartz

/**
 A Quick Look preview of an item that you can embed into your view hierarchy.
 
 To enable quicklock of the preview item by spacebar, use ``QuicklookPreviewable/isPreviewableBySpacebar``
 */
open class QuicklookView: NSView, QuicklookPreviewable {
    var qlPreviewView: QLPreviewView!
    var previousItem: QuicklookPreviewable?
    
    /**
     The item to preview.

     You can preview any item conforming to ``QuicklookPreviewable``. When you set this property, the `QuicklookView` loads the preview asynchronously. Due to this asynchronous behavior, don’t assume that the preview is ready immediately after assigning it to this property.
     */
    open var item: QuicklookPreviewable? {
        get {
            if let item = (qlPreviewView.previewItem as? QuicklookPreviewItem)?.preview {
                return item
            }
            return previousItem
        }
        set {
            if let newValue = newValue, window != nil {
                qlPreviewView.previewItem = QuicklookPreviewItem(newValue)
            } else {
                qlPreviewView.previewItem = nil
            }
            previousItem = newValue
        }
    }

    /**
     Updates the preview to display the currently previewed item.

     When you modify the object that the item property points to, call this method to generate and display the new preview.
     */
    open func refreshItem() {
        qlPreviewView.refreshPreviewItem()
    }

    /// The style of the preview.
    open var style: QLPreviewViewStyle = .normal {
        didSet {
            guard style != oldValue else { return }
            replaceQLPreviewView(includingItem: true)
        }
    }

    /**
     A Boolean value that determines whether the preview starts automatically.

     Set this property to allow previews of movie files to start playback automatically when displayed.
     */
    open var autostarts: Bool {
        get { qlPreviewView.autostarts }
        set { qlPreviewView.autostarts = newValue }
    }

    var shouldCloseWithWindow: Bool {
        get { qlPreviewView.shouldCloseWithWindow }
        set {
            guard newValue != shouldCloseWithWindow else { return }
            qlPreviewView.shouldCloseWithWindow = newValue
        }
    }
    
    open override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow != nil, let previousItem = previousItem {
            replaceQLPreviewView(includingItem: false)
            qlPreviewView.previewItem = QuicklookPreviewItem(previousItem)
            self.previousItem = nil
        }
        super.viewWillMove(toWindow: newWindow)
    }
    
    func replaceQLPreviewView(includingItem: Bool) {
        let item = includingItem ? item : nil
        let starts = autostarts
        let shouldClose = shouldCloseWithWindow
        qlPreviewView.removeFromSuperview()
        qlPreviewView = QLPreviewView(frame: .zero, style: style)
        autostarts = starts
        shouldCloseWithWindow = shouldClose
        self.item = includingItem ? item : nil
        addSubview(withConstraint: qlPreviewView)
    }
    
    /**
     Creates a preview view with the provided item and style.

     - Parameters:
        - item: The item to preview.
        - style: The desired style for the QuicklookView object.
        - frame: The frame rectangle for the initialized `PreviewView` object.

     - Returns: Returns a `QuicklookView` object with the designated item, style and frame.

     */
    public init(item: QuicklookPreviewable, style: QLPreviewViewStyle = .normal, frame: NSRect) {
        super.init(frame: frame)
        sharedInit()
        self.style = style
        self.item = item
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    func sharedInit() {
        qlPreviewView = QLPreviewView(frame: .zero, style: style)
        addSubview(withConstraint: qlPreviewView)
    }
    
    deinit {
        qlPreviewView.removeFromSuperview()
    }
    
    public var previewItemURL: URL? {
        item?.previewItemURL
    }
    
    public var previewItemFrame: CGRect? {
        frameOnScreen
    }
    
    public var previewItemTitle: String? {
        item?.previewItemTitle
    }
}
