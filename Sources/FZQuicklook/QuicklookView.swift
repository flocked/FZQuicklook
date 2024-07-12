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
    /**
     The item to preview.

     You can preview any item conforming to ``QuicklookPreviewable``. When you set this property, the `QuicklookView` loads the preview asynchronously. Due to this asynchronous behavior, don’t assume that the preview is ready immediately after assigning it to this property.
     */
    open var item: QuicklookPreviewable? {
        get { (qlPreviewView.previewItem as? QuicklookPreviewItem)?.preview }
        set {
            if let newValue = newValue {
                if isClosed {
                    replaceQLPreviewView(includingItem: false)
                }
                qlPreviewView.previewItem = QuicklookPreviewItem(newValue)
            } else {
                qlPreviewView.previewItem = nil
            }
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

    /**
     A Boolean value that determines whether the preview should close when its window closes.

     The default value of this property is `true`, which means that the preview automatically closes when its window closes. If you set this property to `false`, close the preview by calling the ``close()`` method when finished with it. Once you close a `QuicklookView`, it won’t accept any more preview items.
     */
    open var shouldCloseWithWindow: Bool {
        get { qlPreviewView.shouldCloseWithWindow }
        set {
            guard newValue != shouldCloseWithWindow else { return }
            qlPreviewView.shouldCloseWithWindow = newValue
        }
    }

    /**
     Closes the view, releasing the current item.

     You only need to call this method if ``shouldCloseWithWindow`` is set to `false`. If you don’t close a `QuicklookView` when you are done using it, your app will leak memory.
     */
    open func close() {
        qlPreviewView.close()
        isClosed = true
    }
    
    func replaceQLPreviewView(includingItem: Bool) {
        isClosed = false
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

    var isClosed: Bool = false

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
        guard !isClosed else { return }
        close()
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
