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
@objc open class QuicklookView: NSView, QuicklookPreviewable {
    var qlPreviewView: QLPreviewView!
    var previousItem: QuicklookPreviewable?
    
    /**
     The item to preview.

     You can preview any item conforming to ``QuicklookPreviewable``. When you set this property, the `QuicklookView` loads the preview asynchronously. Due to this asynchronous behavior, don’t assume that the preview is ready immediately after assigning it to this property.
     */
    public var item: QuicklookPreviewable? {
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
    @objc open var style: QLPreviewViewStyle = .normal {
        didSet {
            guard style != oldValue else { return }
            replaceQLPreviewView(includingItem: true)
        }
    }

    /**
     A Boolean value that determines whether the preview starts automatically.

     Set this property to allow previews of movie files to start playback automatically when displayed.
     */
    @objc open var autostarts: Bool {
        get { qlPreviewView.autostarts }
        set { qlPreviewView.autostarts = newValue }
    }

    @objc open var shouldCloseWithWindow: Bool {
        get { qlPreviewView.shouldCloseWithWindow }
        set {
            guard newValue != shouldCloseWithWindow else { return }
            qlPreviewView.shouldCloseWithWindow = newValue
        }
    }
    
    @objc open override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil {
            qlPreviewView.removeFromSuperview()
        } else if let previousItem = previousItem {
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

/*
 if let size = _items[safe: currentItemIndex]?.targetSize{
     targetSize = size
     targetSize?.height += 43
     targetSize?.width += 10
     Swift.print("targetSize", targetSize ?? "")
 }
 
 frameObservation = previewPanel.observeChanges(for: \.frame) { [weak self] old, new in
     guard let self = self, old != new else { return }
     Swift.print("frame", new, self.isVisible)
     if let targetSize = targetSize, new.size != targetSize {
         var new = new
         new.size = targetSize
         if let visibleFrame = NSScreen.main?.visibleFrame {
             new.center = visibleFrame.center
         }
         self.previewPanel.setFrame(new, display: false)
     }
 }
 
 extension NSMetadataItem {
     var pixelSize: CGSize? {
         guard let height = value(forAttribute: "kMDItemPixelHeight") as? CGFloat, let width = value(forAttribute: "kMDItemPixelWidth") as? CGFloat else { return nil }
         return CGSize(width: width, height: height)
     }
 }
 
 extension QuicklookPreviewItem {
     var targetSize: CGSize? {
         guard let url = previewItemURL else { return nil }
         if let pixelSize = NSMetadataItem(url: url)?.pixelSize {
             return pixelSize
         } else if let pixelSize = ImageSource(url: url)?.properties(at: 0)?.pixelSize {
             return pixelSize
         }
         return nil
     }
 }

 */
