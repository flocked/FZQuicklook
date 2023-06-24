//
//  NSTableView+QLPrevable.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.03.23.
//

import AppKit
import FZSwiftUtils

public extension NSTableView {
    
    /**
     A Boolean value that indicates whether the user can quicklook preview selected rows via pressing space bar.

     
     */
    var isQuicklookPreviewable: Bool {
        get { getAssociatedValue(key: "NSTableView_isQuicklookPreviewable", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSTableView_isQuicklookPreviewable", object: self)
            if newValue == true {
                Self.swizzleTableViewResponderEvents()
            }
        }
    }
    
    func quicklookSelectedRows() {
        self.quicklookRows(at: Array(self.selectedRowIndexes))
    }
    
    func quicklookRows(at rowIndexes: [Int], current: Int? = nil) {
        var previewables: [QuicklookPreviewable] = []
        var currentIndex = 0
        for row in rowIndexes {
            if let previewable = self.QuicklookPreviewable(for: row) {
                previewables.append(previewable)
                if row == current {
                    currentIndex = previewables.count - 1
                }
            }
        }
        
        QuicklookPanel.shared.keyDownResponder = self
        QuicklookPanel.shared.present(previewables, currentItemIndex: currentIndex)
    }
    
    internal func QuicklookPreviewable(for row: Int) -> QuicklookPreviewable? {
        (self.dataSource as? TableViewQuicklookPreviewProvider)?.tableView(self, quicklookPreviewForRow: row)
    }
}
