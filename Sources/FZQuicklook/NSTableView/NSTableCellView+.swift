//
//  NSTableCellView+.swift
//  QuicklookNew
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils


public extension NSTableCellView {
    var quicklookPreview: QuicklookPreviewable? {
        get { getAssociatedValue(key: "NSCollectionView_isQuicklookPreviewable", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_isQuicklookPreviewable", object: self)
            if newValue != nil {
                self.tableView?.isQuicklookPreviewable = true
            }
        }
    }
}


internal extension NSTableCellView {
    /**
     The table view this cell is currently displaying.
     */
    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }
}
