//
//  File.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

internal extension NSTableView {
    static var didSwizzleResponderEvents: Bool {
        get { getAssociatedValue(key: "NSTableView_didSwizzleResponderEvents", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSTableView_didSwizzleResponderEvents", object: self) }
    }
    
    @objc func swizzledKeyDown(with event: NSEvent) {
        Swift.print("swizzledKeyDown", event)
        if isQuicklookPreviewable, event.keyCode == 49 {
            if QuicklookPanel.shared.isVisible == false {
                self.quicklookSelectedRows()
            } else {
                QuicklookPanel.shared.close()
            }
        } else if event.keyCode == 51, let dataSource = self.dataSource as? DeletableTableViewDataSource, dataSource.allowsDeleting == true {
            let indexPaths = Set(self.selectedRowIndexes.compactMap({IndexPath(item: $0, section: 0)}))
            dataSource.deleteItems(for: indexPaths)
        } else {
            self.swizzledKeyDown(with: event)
        }
    }
    
    @objc static func swizzleTableViewResponderEvents() {
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
