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
        get { getAssociatedValue("quicklookGestureRecognizer", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "quicklookGestureRecognizer") }
    }
}

/// A gesture recognizer that detects space bar key events.
class QuicklookGestureRecognizer: NSGestureRecognizer {
    
    var viewObservation: KeyValueObservation?
    var tableView: NSTableView? { view as? NSTableView }
    var collectionView: NSCollectionView? { view as? NSCollectionView }
    var selectedRows: IndexSet = IndexSet()
    var selectionObserver: NotificationToken?
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 {
            if let tableView = tableView {
                if QuicklookPanel.shared.isVisible {
                    QuicklookPanel.shared.close()
                    selectionObserver = nil
                } else {
                    tableView.quicklookSelectedRows()
                    selectedRows = tableView.selectedRowIndexes
                    selectionObserver = NotificationCenter.default.observe(NSTableView.selectionDidChangeNotification, object: tableView) { [weak self] _ in
                        guard let self = self else { return }
                        guard QuicklookPanel.shared.isVisible else {
                            self.selectionObserver = nil
                            return
                        }
                        tableView.quicklookSelectedRows()
                    }
                }
            } else if let item = view as? QuicklookPreviewable {
                QuicklookPanel.shared.present([item])
            }
        }
        super.keyDown(with: event)
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
        setupViewObservation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
