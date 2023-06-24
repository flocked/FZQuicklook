//
//  File.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

internal extension NSCollectionView {
    static var didSwizzleResponderEvents: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_didSwizzleResponderEvents", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_didSwizzleResponderEvents", object: self) }
    }
    
    @objc func swizzledKeyDown(with event: NSEvent) {
        Swift.print("swizzledKeyDown", event.keyCode)
        if isQuicklookPreviewable, event.keyCode == 49 {
            if QuicklookPanel.shared.isVisible == false {
                self.quicklookSelectedItems()
            }
        } else {
            let previousSelectionIndexPaths = self.selectionIndexPaths
            self.swizzledKeyDown(with: event)
            if QuicklookPanel.shared.isVisible, selectionIndexPaths != previousSelectionIndexPaths {
                self.quicklookSelectedItems()
            }
        }
    }
    
    @objc static func swizzleCollectionViewResponderEvents() {
        Swift.print("swizzleCollectionViewResponderEvents")
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
}
