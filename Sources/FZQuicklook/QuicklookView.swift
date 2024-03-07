//
//  QuicklookView.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

import AppKit
import FZSwiftUtils
import Quartz

/// A Quick Look preview of an item that you can embed into your view hierarchy.
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
                qlPreviewView.previewItem = QuicklookPreviewItem(newValue)
            } else {
                qlPreviewView.previewItem = nil
            }
        }
    }

    func replaceQLPreviewView(includingItem: Bool) {
        qlPreviewView.removeFromSuperview()
        let autostarts = autostarts
        let shouldClose = shouldCloseWithWindow
        let item = includingItem ? item : nil
        qlPreviewView = QLPreviewView(frame: .zero, style: style)
        self.autostarts = autostarts
        shouldCloseWithWindow = shouldClose
        self.item = item
        addSubview(withConstraint: qlPreviewView)
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
            if style != oldValue {
                replaceQLPreviewView(includingItem: true)
            }
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
            // setupWindowObserver()
        }
    }

    /**
     Closes the view, releasing the current item.

     Once a QuicklookView is closed, it won’t accept any more preview items. You only need to call this method if ``shouldCloseWithWindow`` is set to false. If you don’t close a `QuicklookView when you are done using it, your app will leak memory.
     */
    open func close() {
        qlPreviewView.close()
        isClosed = true
    }

    var isClosed: Bool = false
    var windowObserver: NSKeyValueObservation? = nil
    var windowCloseObserver: NotificationToken? = nil

    /*
     func setupWindowCloseObserver() {

     }

     func setupWindowObserver() {
         if shouldCloseWithWindow {
             windowObserver = self.observe(\.window) { [weak self] old, new in
                 guard let self = self, old != new else { return }
                 if let new = new {
                     self.windowCloseObserver =    NotificationCenter.default.observe(NSWindow.willCloseNotification, object: new) { _ in
                         self.isClosed = true
                         self.windowCloseObserver = nil
                         self.windowObserver = nil
                     }
                 } else {
                     self.isClosed = true
                 }
             }
         } else {
             windowObserver = nil
             windowCloseObserver = nil
         }
     }
      */

    /**
     Creates a preview view with the provided item and style.

     - Parameters:
        - item: The item to preview.
        - style: The desired style for the QuicklookView object.
        - frame: The frame rectangle for the initialized `PreviewView` object.

     - Returns: Returns a `QuicklookView` object with the designated item, style and frame.

     */
    public init(item: QuicklookPreviewable, style _: QLPreviewViewStyle = .normal, frame: NSRect) {
        super.init(frame: frame)
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
