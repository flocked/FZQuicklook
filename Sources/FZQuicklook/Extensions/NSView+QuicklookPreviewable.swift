//
//  NSView+Quicklook.swift
//
//
//  Created by Florian Zand on 17.03.24.
//

import AppKit
import FZSwiftUtils

extension QuicklookPreviewable where Self: NSView {
    /**
     A Boolean value indicating whether the user can quicklook the view by pressing space bar.
     
     If `true`, the view is first responder and the user presses space bar, the quicklook panel is opened previewing the view.
     */
    public var isPreviewableBySpacebar: Bool {
        get { quicklookGestureRecognizer != nil }
        set {
            guard newValue != isPreviewableBySpacebar else { return }
            if newValue {
                quicklookGestureRecognizer = QuicklookGestureRecognizer()
                addGestureRecognizer(quicklookGestureRecognizer!)
            } else {
                quicklookGestureRecognizer?.removeFromView()
                quicklookGestureRecognizer = nil
            }
        }
    }
    
    var quicklookGestureRecognizer: QuicklookGestureRecognizer? {
        get { getAssociatedValue(key: "quicklookGestureRecognizer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "quicklookGestureRecognizer", object: self) }
    }
}

/// A gesture recognizer that detects space bar key events.
class QuicklookGestureRecognizer: NSGestureRecognizer {
    
    var viewObservation: KeyValueObservation?
    var tableView: NSTableView? { view as? NSTableView }
    var collectionView: NSCollectionView? { view as? NSCollectionView }
    var selectedRows: IndexSet = IndexSet()
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 {
            if let tableView = tableView {
                if QuicklookPanel.shared.isVisible {
                    QuicklookPanel.shared.close()
                } else {
                    tableView.quicklookSelectedRows()
                    selectedRows = tableView.selectedRowIndexes
                }
            } else if let item = view as? QuicklookPreviewable {
                QuicklookPanel.shared.present([item])
            }
        }
        super.keyDown(with: event)
    }
    
    override func magnify(with event: NSEvent) {
        super.magnify(with: event)
    }
        
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard QuicklookPanel.shared.isVisible else { return }
        if let tableView = tableView,
            tableView.selectedRowIndexes.isEmpty == false,
            tableView.selectedRowIndexes != selectedRows {
            selectedRows = tableView.selectedRowIndexes
            tableView.quicklookSelectedRows()
        }
    }
    
    func setupViewObservation() {
        viewObservation = observeChanges(for: \.view) { [weak self] old, new in
            guard let self = self else { return }
            if new == nil, let old = old {
                let task = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    old.addGestureRecognizer(self)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
            }
        }
    }
    
    func removeFromView() {
        viewObservation = nil
        view?.removeGestureRecognizer(self)
    }
    
    convenience init() {
        self.init(target: nil, action: nil)
    }
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        Swift.print("gesture init")
        setupViewObservation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*
extension NSImageView {
    public var isQuicklookPreviable: Bool {
        get { quicklookGestureRecognizer != nil }
        set {
            guard newValue != isQuicklookPreviable else { return }
            if newValue {
                quicklookGestureRecognizer = QuicklookGestureRecognizer()
                addGestureRecognizer(quicklookGestureRecognizer!)
            } else {
                quicklookGestureRecognizer?.removeFromView()
                quicklookGestureRecognizer = nil
            }
        }
    }
    
    var quicklookGestureRecognizer: QuicklookGestureRecognizer? {
        get { getAssociatedValue(key: "quicklookGestureRecognizer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "quicklookGestureRecognizer", object: self) }
    }
        
    var imageObserver: KeyValueObservation? {
        get { getAssociatedValue(key: "imageObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "imageObserver", object: self) }
    }
    
    func setupImageObserver(isActive: Bool) {
        if isActive, imageObserver == nil {
            imageObserver = observeChanges(for: \.image) { [weak self] old, new in
                guard let self = self, QuicklookPanel.shared.isVisible, (QuicklookPanel.shared.items.first as? QuicklookPreviewItem)?.id == "imageView" else { return }
                if let oldImage = old {
                    self.removeQuicklookImage(oldImage)
                }
                self.openQuicklookPanel()
            }
        } else if !isActive {
            imageObserver = nil
        }
    }
    
    func openQuicklookPanel() {
        if let image = image {
            guard let item = quicklookItem(for: image) else { return }
            QuicklookPanel.shared.present([item])
        } else {
            QuicklookPanel.shared.present([])
        }
        guard QuicklookPanel.shared.isVisible else { return }
        if imageObserver == nil {
            imageObserver = observeChanges(for: \.image) { [weak self] old, new in
                guard let self = self, QuicklookPanel.shared.isVisible, QuicklookPanel.shared.items.first?.previewItemID == "imageView" else { return }
                if let oldImage = old {
                    self.removeQuicklookImage(oldImage)
                }
                self.openQuicklookPanel()
            }
        }
        QuicklookPanel.shared.panelDidCloseHandler = { [weak self] in
            guard let self = self else { return }
            self.imageObserver = nil
        }
    }
        
    func quicklookItem(for image: NSImage) -> QuicklookPreviewItem? {
        guard let url = createQuicklookImage(image) else { return nil }
        return QuicklookPreviewItem(url, view: self)
    }
    
    var quicklookItem: QuicklookPreviewable? {
        guard let image = image, let url = createQuicklookImage(image) else { return nil }
        return QuicklookPreviewItem(url, view: self)
    }
    
    func createQuicklookImage(_ image: NSImage) -> URL? {
        let url = quicklookImageURL(image)
        guard !FileManager.default.fileExists(at: url) else { return url }
        do {
            try image.tiffRepresentation?.write(to: url)
            return url
        } catch {
            return nil
        }
    }
    
    func removeQuicklookImage(_ image: NSImage) {
        let url = quicklookImageURL(image)
        guard FileManager.default.fileExists(at: url) else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    func quicklookImageURL(_ image: NSImage) -> URL {
        let identifier = ObjectIdentifier(image).hashValue.string
        return FileManager.default.temporaryDirectory.appendingPathComponent(identifier).appendingPathExtension("png")
    }
}
 */
