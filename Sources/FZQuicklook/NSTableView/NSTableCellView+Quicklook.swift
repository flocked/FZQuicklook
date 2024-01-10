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
     The quicklook preview for the table cell.

     To present the preview use `NSTableView` ``AppKit/NSTableView/quicklookSelectedRows()`` or ``AppKit/NSTableView/quicklookRows(at:current:)``.

     Make sure to reset it's value inside `prepareForReuse()`.
     */
    var quicklookPreview: QuicklookPreviewable? {
        get { getAssociatedValue(key: "quicklookPreview", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "quicklookPreview", object: self)
            if newValue != nil {
                tableView?.isQuicklookPreviewable = true
            }
        }
    }
}
