//
//  NSTableViewDataSource+Quicklook.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils

/// A `NSTableView` Quicklook preview provider.
public protocol NSTableViewQuicklookProvider {
    /**
     Asks your data source object for a quicklook preview that corresponds to the specified row in the table view.
     */
    func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable?
}

public extension NSTableViewQuicklookProvider {
    /**
     Asks your data source object for a quicklook preview that corresponds to the specified row in the table view.
     */
    func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        if let rowView = tableView.rowView(atRow: row, makeIfNecessary: false), let preview = rowView.cellViews.first(where: { $0.quicklookPreview != nil })?.quicklookPreview {
            return QuicklookPreviewItem(preview, view: rowView)
        }
        return nil
    }
}

@available(macOS 11.0, *)
extension NSTableViewDiffableDataSource: NSTableViewQuicklookProvider {
    public func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        if let previewable = itemIdentifier(forRow: row) as? QuicklookPreviewable {
            let rowView = tableView.rowView(atRow: row, makeIfNecessary: false)
            return QuicklookPreviewItem(previewable, view: rowView)
        } else if let rowView = tableView.rowView(atRow: row, makeIfNecessary: false), let preview = rowView.cellViews.first(where: { $0.quicklookPreview != nil })?.quicklookPreview {
            return QuicklookPreviewItem(preview, view: rowView)
        }
        return nil
    }
}
