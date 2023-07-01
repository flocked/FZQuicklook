//
//  QuicklookPanel.swift
//  FZExtensions
//
//  Created by Florian Zand on 08.05.22.
//

import AppKit
import FZSwiftUtils
import Quartz

/**
  QuicklookPanel presents Quick Look previews of files to a panel simliar to Finder's Quick Look.

  Every application has a single shared instance of QuicklookPanel accessible through *shared*.

  QuicklookPanel previews any object conforming to QLPreviable. The protocol requires a file URL *quicklookURL* and optionally a title *quicklookTitle*.

  ```
 struct Item: QLPreviable {
 let quicklookURL: URL
 let quicklookTitle: String?
 }
  ```

  NSCollectionView can present Quick Look previews of selected items that conform to QLPreviable.

  ```
  MyCollectionItem: NSCollectionViewItem, QLPreviable {
  var quicklookURL: URL
  var quicklookTitle: String?
  }

  collectionView.quicklookItems(itemsToPreview)
  // or preview selected items
  collectionView.quicklookSelectedItems()
  ```

  NSTableView can  preset Quick Look previews of selected rows that conform to QLPreviable.

  ```
  MyTableRowView: NSTableRowView, QLPreviable {
  var quicklookURL: URL
  var quicklookTitle: String?
  }

  tableView.quicklookRows(rowsToPreview)
  // or preview selected rows
  tableView.quicklookSelectedRows()
  ```
  */
public class QuicklookPanel: NSResponder {
    /**
     The singleton quicklook panel instance.
     */
    public static let shared = QuicklookPanel()

    /// The items the quicklook panel is previewing.
    public var items: [QuicklookPreviewable] {
        get { _items.compactMap({$0.preview}) }
        set { _items = newValue.compactMap({ QuicklookPreviewItem($0) }) }
    }
    
    /**
     A Boolean value that indicates whether the panel is visible onscreen (even when it’s obscured by other windows).

     The value of this property is true when the panel is onscreen (even if it’s obscured by other windows); otherwise, false.
     */
    public var isVisible: Bool {
        return previewPanel.isVisible
    }

    /**
     The index of the current preview item.
     */
    public var currentItemIndex: Int {
        get { previewPanel.currentPreviewItemIndex }
        set { previewPanel.currentPreviewItemIndex = newValue }
    }
    

    /**
     The currently previewed item.

     The value is nil if there’s no current preview item.
     */
    public var currentItem: QuicklookPreviewable? {
        if items.isEmpty == false, currentItemIndex < items.count {
            return items[currentItemIndex]
        }
        return nil
    }

    /**
     A Boolean value that indicates whether the panel is removed from the screen when its application becomes inactive.

     The value of this property is true if the panel is removed from the screen when its application is deactivated; false if it remains onscreen. The default value is true.
     */
    public var hidesOnAppDeactivate: Bool {
        get { previewPanel.hidesOnDeactivate }
        set { previewPanel.hidesOnDeactivate = newValue }
    }
    
    /**
     The responder to handle keyDown events.

     The responder that handles events whenever the user presses a key when the panel is open.

     */
    public weak var keyDownResponder: NSResponder? = nil
    
    
    /**
     The handler gets called when the panel did close.
     */
    public var panelDidCloseHandler: (()->())? = nil

    /**
     Opens the quicklook panel and previews the items.

     - Parameters items: The items to preview.
     - Parameters currentItemIndex: The index of the current preview item. The default value is 0.

     */
    public func present(_ items: [QuicklookPreviewable], currentItemIndex: Int = 0) {
        DispatchQueue.main.async {
            self.items = items
            self.open()
            if items.isEmpty == false {
                self.currentItemIndex = currentItemIndex
            }
        }
    }
    
    /// Opens the quicklook panel and displays the previews thr `items`.
    public func open() {
        if previewPanel.isVisible == false {
            itemsProviderWindow = NSApp.keyWindow
            NSApp.nextResponder = self
            previewPanel.updateController()
            
            if needsReload {
                needsReload = false
                self.previewPanel.reloadData()
            }
            
            previewPanel.makeKeyAndOrderFront(nil)

        }
    }

    /// Closes the quicklook panel.
    public func close() {
        if previewPanel.isVisible == true {
            previewPanel.close()
          //  previewPanel.orderOut(nil)
            items.removeAll()
            itemsProviderWindow = nil
            keyDownResponder = nil
        }
    }

    /// Recomputes the preview of the current preview item.
    public func refreshCurrentPreviewItem() {
        previewPanel.refreshCurrentPreviewItem()
    }

    /**
     Enters the panel in full screen mode.

     - Returns: true if the panel was able to enter full screen mode; otherwise, false.
     */
    public func enterFullScreen() -> Bool {
        return previewPanel.enterFullScreenMode(nil)
    }

    /// Exists the panels full screen mode.
    public func exitFullScreen() {
        previewPanel.exitFullScreenMode()
    }

    /**
     The property that indicates whether the panel is in full screen mode.

     The value is true if the panel is currently open and in full screen mode; otherwise it’s false.
     */
    public var isInFullScreen: Bool {
        return previewPanel.isInFullScreenMode
    }
    
    internal var needsReload = false
    internal weak var itemsProviderWindow: NSWindow? = nil
    
    internal var _items: [QuicklookPreviewItem] = [] {
        didSet {
            if isVisible {
                self.previewPanel.reloadData()
            } else {
                self.needsReload = true
            }
            if _items.isEmpty {
                self.currentItemIndex = NSNotFound
            } else if self.currentItemIndex >= _items.count {
                self.currentItemIndex = _items.count - 1
            }
        }
    }
        
    override public func acceptsPreviewPanelControl(_: QLPreviewPanel!) -> Bool {
        return true
    }

    override public func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.dataSource = self
        panel.delegate = self
    }

    override public func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.dataSource = nil
        panel.delegate = nil
        self.panelDidCloseHandler?()
        self.panelDidCloseHandler = nil
    }

    internal var previewPanel: QLPreviewPanel {
        QLPreviewPanel.shared()
    }

    override internal init() {
        super.init()
    }

    @available(*, unavailable)
    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuicklookPanel: QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    public func previewPanel(_: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if let keyDownResponder = keyDownResponder, event.type == .keyUp {
            keyDownResponder.keyDown(with: event)
        }
        return true
    }

    public func previewPanel(_: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        if let frame = (item as? QuicklookPreviewItem)?.previewItemFrame {
            return frame
        }

        if let itemsProviderWindow = itemsProviderWindow {
            return itemsProviderWindow.frame
        }

        if let screenFrame = NSScreen.main?.visibleFrame {
            var frame = CGRect(origin: .zero, size: screenFrame.size * 0.5)
            frame.center = screenFrame.center
            return frame
        }

        return .zero
    }

    public func previewPanel(_: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return _items[index]
    }

    public func numberOfPreviewItems(in _: QLPreviewPanel!) -> Int {
        return _items.count
    }

    public func previewPanel(_: QLPreviewPanel!, transitionImageFor item: QLPreviewItem!, contentRect _: UnsafeMutablePointer<NSRect>!) -> Any! {
        return (item as? QuicklookPreviewable)?.previewItemTransitionImage
    }
}
