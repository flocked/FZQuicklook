//
//  File.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

internal extension NSCollectionView {
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSCollectionView_keyDownMonitor", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_keyDownMonitor", object: self) }
    }
    
    func setupKeyDownMonitor() {
        if isQuicklookPreviewable {
            guard keyDownMonitor == nil else { return }
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                Swift.print("keydownMonitor", self?.window?.firstResponder ?? "")
                guard let self = self, self.window?.firstResponder == self else { return event }
                if self.isQuicklookPreviewable, event.keyCode == 49 {
                    if QuicklookPanel.shared.isVisible == false {
                        self.quicklookSelectedItems()
                    }
                } else {
                    let previousSelectionIndexPaths = self.selectionIndexPaths
                    if QuicklookPanel.shared.isVisible, selectionIndexPaths != previousSelectionIndexPaths {
                        self.quicklookSelectedItems()
                    }
                }
                return event
            })
        } else if let keyDownMonitor = self.keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
    }
    
    /*
    static var didSwizzleResponderEvents: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_didSwizzleResponderEvents", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_didSwizzleResponderEvents", object: self) }
    }
    
    @objc func swizzledKeyDown(with event: NSEvent) {
        if isQuicklookPreviewable, event.keyCode == 49 {
            if QuicklookPanel.shared.isVisible == false {
                self.quicklookSelectedItems()
            }
        } else {
            let previousSelectionIndexPaths = self.selectionIndexPaths
            swizzledKeyDown(with: event)
            if QuicklookPanel.shared.isVisible, selectionIndexPaths != previousSelectionIndexPaths {
                self.quicklookSelectedItems()
            }
        }
    }
    
    @objc static func swizzleCollectionViewResponderEvents() {
        if (didSwizzleResponderEvents == false) {
            self.didSwizzleResponderEvents = true
            do {
                _ = try Swizzle(NSCollectionView.self) {
                    #selector(keyDown(with: )) <-> #selector(swizzledKeyDown(with:))
                }
            } catch {
                Swift.print(error)
            }
        }
    }
     */
}
