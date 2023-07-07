//
//  File.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils


// Configurates a monitor for keyDown events on table views with `isQuicklookPreviewable` enabled. A spacebar event will open the `QuicklookPanel`.
internal extension NSTableView {
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSTableView_keyDownMonitor", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSTableView_keyDownMonitor", object: self) }
    }
    
    func setupKeyDownMonitor() {
        if isQuicklookPreviewable {
            guard keyDownMonitor == nil else { return }
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                guard let self = self, self.window?.firstResponder == self else { return event }
                if self.isQuicklookPreviewable, event.keyCode == 49 {
                    if QuicklookPanel.shared.isVisible == false {
                        self.quicklookSelectedRows()
                        return nil
                    }
                } else {
                    if QuicklookPanel.shared.isVisible {
                        let previousSelectedRowIndexes = self.selectedRowIndexes
                        self.keyDown(with: event)
                        if self.selectedRowIndexes != previousSelectedRowIndexes {
                            self.quicklookSelectedRows()
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
