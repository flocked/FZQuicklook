//
//  NSTableCellView+Quicklook.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils


public extension NSTableCellView {
    /**
     The quicklook preview for the ce,,.
     
     To present the preview use `NSTableView` `quicklookSelectedRows()`or `quicklookRows(at:_, current:)`.
     
     Make sure to reset it's value inside `prepareForReuse()`.
     */
    var quicklookPreview: QuicklookPreviewable? {
        get { getAssociatedValue(key: "NSCollectionView_isQuicklookPreviewable", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_isQuicklookPreviewable", object: self)
            if newValue != nil {
                self.tableView?.isQuicklookPreviewable = true
            }
        }
    }
}
