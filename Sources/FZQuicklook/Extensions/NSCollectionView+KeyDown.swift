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
                guard let self = self, self.window?.firstResponder == self else { return event }
                if self.isQuicklookPreviewable, event.keyCode == 49 {
                    if QuicklookPanel.shared.isVisible == false {
                        self.quicklookSelectedItems()
                    }
                } else {
                    if QuicklookPanel.shared.isVisible {
                        let previousSelectionIndexPaths = self.selectionIndexPaths
                        self.keyDown(with: event)
                        if self.selectionIndexPaths != previousSelectionIndexPaths {
                            self.quicklookSelectedItems()
                        }
                        return nil
                    }
                }
                return event
            })
        } else if let keyDownMonitor = self.keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
    }
}
