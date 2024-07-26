//
//  QuicklookPanel.swift
//
//
//  Created by Florian Zand on 08.05.22.
//

import AppKit
import FZSwiftUtils
import Quartz

/**
  QuicklookPanel presents Quick Look previews of files to a panel simliar to Finder's Quick Look.

  Every application has a single shared instance of QuicklookPanel accessible through ``shared``.

  QuicklookPanel previews any object conforming to ``QuicklookPreviewable``. The protocol requires a file
 URL to preview via  ``QuicklookPreviewable/previewItemURL`` and optionally a title  via  ``QuicklookPreviewable/previewItemTitle-65rix``.

  ```swift
 struct Item: QLPreviable {
 let quicklookURL: URL
 let quicklookTitle: String?
 }
  ```

  NSCollectionView can present Quick Look previews of selected items that conform to QLPreviable.

  ```swift
  MyCollectionItem: NSCollectionViewItem, QLPreviable {
  var quicklookURL: URL
  var quicklookTitle: String?
  }

  collectionView.quicklookItems(itemsToPreview)
  // or preview selected items
  collectionView.quicklookSelectedItems()
  ```

  NSTableView can  preset Quick Look previews of selected rows that conform to QLPreviable.

  ```swift
  MyTableRowView: NSTableRowView, QLPreviable {
  var quicklookURL: URL
  var quicklookTitle: String?
  }

  tableView.quicklookRows(rowsToPreview)
  // or preview selected rows
  tableView.quicklookSelectedRows()
  ```
  */
@objc open class QuicklookPanel: NSResponder {
    /// The singleton quicklook panel instance.
    public static let shared = QuicklookPanel()

    /// The items the quicklook panel is previewing.
    public var items: [QuicklookPreviewable] {
        get { _items.compactMap(\.preview) }
        set { _items = newValue.compactMap { QuicklookPreviewItem($0) } }
    }

    /**
     A Boolean value that indicates whether the panel is visible onscreen (even when it’s obscured by other windows).

     The value of this property is `true` when the panel is onscreen (even if it’s obscured by other windows); otherwise, `false.
     */
    @objc open var isVisible: Bool {
        previewPanel.isVisible
    }

    /**
     The index of the current preview item.

     Changing the index will change to current previewed item.

     The value is `NSNotFound` if there’s no current preview item.
     */
    @objc open var currentItemIndex: Int {
        get { previewPanel.currentPreviewItemIndex }
        set { 
            if isVisible {
                previewPanel.currentPreviewItemIndex = newValue
            }
            _currentItemIndex = !isVisible ? newValue : nil
        }
    }
    
    var _currentItemIndex: Int? {
        didSet { updateCurrentItemIndex() }
    }
    
    func updateCurrentItemIndex() {
        if let index = _currentItemIndex, isVisible {
            currentItemIndex = index
            _currentItemIndex = nil
        }
    }
    
    public var currentItemHandler: ((QuicklookPreviewable, Int)->())? = nil
    
    /**
     The currently previewed item.

     The value is nil if there’s no current preview item.
     */
    public var currentItem: QuicklookPreviewable? {
        if !items.isEmpty, currentItemIndex < items.count {
            return items[currentItemIndex]
        }
        return nil
    }

    /**
     A Boolean value that indicates whether the panel is removed from the screen when its application becomes inactive.

     The value of this property is true if the panel is removed from the screen when its application is deactivated; false if it remains onscreen. The default value is true.
     */
    @objc open var hidesOnAppDeactivate: Bool {
        get { previewPanel.hidesOnDeactivate }
        set { previewPanel.hidesOnDeactivate = newValue }
    }

    /**
     The handler that gets called on `keyDown` events.

     The handler gets called whenever the panel is open and the user presses a key.
     
     The handler is set to `nil` after the panel closes.
     */
    @objc open var keyDownHandler: ((NSEvent)->())? = nil

    /**
     The handler that gets called when the panel closes
    
     The handler is set to `nil` after the panel closes.
     */
    @objc open var panelDidCloseHandler: (() -> Void)? = nil

    /**
     Opens the quicklook panel and previews the specified items.

     To respond to keyDown events (e.g. to advance the selection of a table view or collection view), use ``keyDownResponder``.

     - Parameter items: The items to preview.
     - Parameter currentItemIndex: The index of the current preview item. The default value is 0.
     */
    public func present(_ items: [QuicklookPreviewable], currentItemIndex: Int = 0) {
        DispatchQueue.main.async {
            self.items = items
            self.open()
            self._currentItemIndex = currentItemIndex < items.count ? currentItemIndex : 0
        }
    }

    /**
     Opens the quicklook panel and displays the previews the current ``items``.

     To respond to keyDown events (e.g. to advance the selection of a table view or collection view), use ``keyDownResponder``.
     */
    @objc open func open() {
        guard !previewPanel.isVisible else { return }
        itemsProviderWindow = NSApp.keyWindow
        NSApp.nextResponder = self
        previewPanel.updateController()
        previewPanel.makeKeyAndOrderFront(nil)

        if needsReload {
            needsReload = false
            previewPanel.reloadData()
        }
        updateCurrentItemIndex()
    }

    /**
     Closes the quicklook panel.

     After closing the panel, both ``keyDownResponder`` and ``panelDidCloseHandler`` are set to `nil`.
     */
    @objc open func close() {
        guard isVisible else { return }
        currentItemHandler = nil
        previewPanel.close()
        reset()
    }

    /// Recomputes the preview of the current preview item.
    @objc open func refreshCurrentItem() {
        previewPanel.refreshCurrentPreviewItem()
    }

    /**
     Enters the panel in full screen mode.

     - Returns: `true` if the panel was able to enter full screen mode; otherwise, `false`.
     */
    @objc open func enterFullScreen() -> Bool {
        previewPanel.enterFullScreenMode(nil)
    }

    /// Exists the panels full screen mode.
    @objc open func exitFullScreen() {
        previewPanel.exitFullScreenMode()
    }

    /**
     A Boolean value that indicates whether the panel is in full screen mode.

     The value is `true` if the panel is currently open and in full screen mode; otherwise it’s `false`.
     */
    @objc open var isInFullScreen: Bool {
        previewPanel.isInFullScreenMode
    }

    var needsReload = false
    var currentItemIndexObservation: KeyValueObservation? = nil
    weak var itemsProviderWindow: NSWindow? = nil
    
    var previewPanel: QLPreviewPanel {
        QLPreviewPanel.shared()
    }

    func reset() {
        items.removeAll()
        itemsProviderWindow = nil
        keyDownHandler = nil
        needsReload = false
        panelDidCloseHandler = nil
    }

    var _items: [QuicklookPreviewItem] = [] {
        didSet {
            if isVisible {
                previewPanel.reloadData()
            } else {
                needsReload = true
            }
            if _items.isEmpty {
                _currentItemIndex = NSNotFound
            } else if currentItemIndex >= _items.count {
                _currentItemIndex = _items.count - 1
            }
        }
    }

    override public func acceptsPreviewPanelControl(_: QLPreviewPanel!) -> Bool {
        true
    }

    override public func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.dataSource = self
        panel.delegate = self
    }

    override public func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.dataSource = nil
        panel.delegate = nil
        panelDidCloseHandler?()
        reset()
    }
    
    override init() {
        super.init()
        hidesOnAppDeactivate = true
        currentItemIndexObservation = previewPanel.observeChanges(for: \.currentPreviewItemIndex) { old, new in
            if self.isVisible, let currentItem = self.currentItem {
                self.currentItemHandler?(currentItem, self.currentItemIndex)
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuicklookPanel: QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    public func previewPanel(_: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if event.type == .keyUp {
            if event.keyCode == 49 || event.keyCode == 53 {
                currentItemHandler = nil
            }
        } else if event.type == .keyDown {
            keyDownHandler?(event)
        }
        return true
    }

    public func previewPanel(_: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        (item as? QuicklookPreviewItem)?.previewItemFrame ?? .zero
    }

    public func previewPanel(_: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        _items[safe: index]
    }

    public func numberOfPreviewItems(in _: QLPreviewPanel!) -> Int {
        _items.count
    }

    public func previewPanel(_: QLPreviewPanel!, transitionImageFor item: QLPreviewItem!, contentRect _: UnsafeMutablePointer<NSRect>!) -> Any! {
        (item as? QuicklookPreviewable)?.previewItemTransitionImage
    }
}

extension NSEvent {
    func setType(_ type: EventType) {
        setValue(type.rawValue, forKey: "type")
    }
}
