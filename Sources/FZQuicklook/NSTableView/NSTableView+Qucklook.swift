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
     A Boolean value that indicates whether the user can quicklook selected rows via space bar.
     
     There are several ways to provide quicklook previews:
     - NSTableCellView's `quicklookPreview`:
     ```
     tableCell.quicklookPreview = URL(fileURLWithPath: "someFile.png")
     ```
     - NSTableView's datasource `tableView(_:,  quicklookPreviewForRow:)`:
     ```
     func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        let item = tableItems[row]
        return item.fileURL
     }

     ```
     - A NSTableViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`
     ```
     struct TableItem: Hashable, QuicklookPreviewable {
        let text: String
        let image: NSImage
        let previewItemURL: URL?
     }
     
    tableView.dataSource = NSTableViewDiffableDataSource<Section, TableItem>(tableView: tableView) { tableView, tableColumn, row, tableItem in
     
        let tableCell = tableView.makeView(withIdentifier: "TableItemCell", owner: nil) as! NSTableCellView
        tableCell.imageView?.image = tableItem.image
        tableCell.textField?.stringValue = tableItem.text
     
        return tableCell
    }
     // …
     tableView.quicklookSelectedItems()
     ```
     */
    var isQuicklookPreviewable: Bool {
        get { getAssociatedValue(key: "NSTableView_isQuicklookPreviewable", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSTableView_isQuicklookPreviewable", object: self)
            if newValue == true {
                Self.swizzleTableViewResponderEvents()
            }
        }
    }
    
    /**
     Opens `QuicklookPanel` that presents quicklook previews of the selected rows.
     */
    func quicklookSelectedRows() {
        self.quicklookRows(at: Array(self.selectedRowIndexes))
    }
    
    /**
     Opens `QuicklookPanel` that presents quicklook previews for the rows at the specified indexes.
     - Parameters rowIndexes: The indexes of the rows.
     - Parameters current:
     */
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
        (self.dataSource as? NSTableViewQuicklookProvider)?.tableView(self, quicklookPreviewForRow: row)
    }
}
