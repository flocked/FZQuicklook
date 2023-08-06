//
//  NSTableView+Qucklook.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.03.23.
//

import AppKit
import FZSwiftUtils

public extension NSTableView {
    /**
     A Boolean value that indicates whether the user can quicklook selected rows by pressing space bar.
     
     There are several ways to provide quicklook previews:
     - NSTableCellView's ``AppKit/NSTableCellView/quicklookPreview``
     ```swift
     tableCell.quicklookPreview = URL(fileURLWithPath: "someFile.png")
     // …
     tableView.quicklookSelectedCells()
     ```swift
     - NSTableView's datasource `tableView(_:,  quicklookPreviewForRow:)`
     ```
     func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        let galleryItem = galleryItems[row]
        return galleryItem.fileURL
     }
     ```
     - A `NSTableViewDiffableDataSource with an ItemIdentifierType conforming to ``QuicklookPreviewable``
     ```swift
     struct GalleryItem: Hashable, QuicklookPreviewable {
         let title: String
         let imageURL: URL
         
         let previewItemURL: URL? {
         return imageURL
         }
         
         let previewItemTitle: String? {
         return title
         }
     }
     
    tableView.dataSource = NSTableViewDiffableDataSource<Section, TableItem>(tableView: tableView) { tableView, tableColumn, row, galleryItem in
     
        let tableCell = tableView.makeView(withIdentifier: "TableItemCell", owner: nil) as! NSTableCellView
        tableCell.imageView?.image = NSImage(contentsOf: galleryItem.imageURL)
        tableCell.textField?.stringValue = galleryItem.title
     
        return tableCell
    }
     ```
     */
    var isQuicklookPreviewable: Bool {
        get { getAssociatedValue(key: "NSTableView_isQuicklookPreviewable", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSTableView_isQuicklookPreviewable", object: self)
            self.setupKeyDownMonitor()
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
            if let previewable = self.quicklookPreviewable(for: row) {
                previewables.append(previewable)
                if row == current {
                    currentIndex = previewables.count - 1
                }
            }
        }

        if QuicklookPanel.shared.isVisible == false {
            QuicklookPanel.shared.keyDownResponder = self
            QuicklookPanel.shared.present(previewables, currentItemIndex: currentIndex)
        } else {
            QuicklookPanel.shared.items = previewables
            if currentIndex != QuicklookPanel.shared.currentItemIndex {
                QuicklookPanel.shared.currentItemIndex = currentIndex
            }
        }
    }
    
    internal func quicklookPreviewable(for row: Int) -> QuicklookPreviewable? {
        (self.dataSource as? NSTableViewQuicklookProvider)?.tableView(self, quicklookPreviewForRow: row)
    }
}
