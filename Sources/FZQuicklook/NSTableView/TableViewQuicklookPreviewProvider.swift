//
//  aa.swift
//  QuicklookNew
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils

public protocol TableViewQuicklookPreviewProvider {
    func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable?
}

/*
@available(macOS 11.0, *)
extension NSTableViewDiffableDataSource: TabkeViewQuicklookPreviewProvider where ItemIdentifierType: QuicklookPreviewable {
    public func tableView(_ tableView: NSTableView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let rowView = tableView.rowView(atRow: row, makeIfNecessary: false), let previewable = itemIdentifier(forRow: indexPath.item) as? QuicklookPreviewable {
            return QuicklookPreviewItem(previewable, view: rowView)
        }
        return nil
    }
}

extension NSTableViewDataSource: TabkeViewQuicklookPreviewProvider {
    public func tableView(_ tableView: NSTableView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
    if let rowView = tableView.rowView(atRow: row, makeIfNecessary: false), let preview = rowView.cellViews.first(where: {$0.quicklookPreview != nil})?.quicklookPreview {
        return QuicklookPreviewItem(preview, view: rowView)
    }
return nil
    }
}

*/

