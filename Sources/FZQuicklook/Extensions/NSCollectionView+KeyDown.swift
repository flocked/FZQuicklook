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
        if isQuicklookPreviewable, event.keyCode == 49 {
            if QuicklookPanel.shared.isVisible == false {
                self.quicklookSelectedItems()
            }
        } else {
            self.swizzledKeyDown(with: event)
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
}
