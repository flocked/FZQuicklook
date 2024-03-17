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
      ```
      - NSTableView's datasource `tableView(_:,  quicklookPreviewForRow:)`
      ```swift
      func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
         let galleryItem = galleryItems[row]
         return galleryItem.fileURL
      }
      ```
      - A `NSTableViewDiffableDataSource` with an ItemIdentifierType conforming to ``QuicklookPreviewable``
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

     tableView.dataSource = NSTableViewDiffableDataSource<Section, GalleryItem>(tableView: tableView) { tableView, tableColumn, row, galleryItem in
         // configurate cell
     }
      ```
      */
    var isQuicklookPreviewable: Bool {
        get { quicklookGestureRecognizer != nil }
        set { 
            guard newValue != isQuicklookPreviewable else { return }
            if newValue {
                quicklookGestureRecognizer = QuicklookGestureRecognizer()
                addGestureRecognizer(quicklookGestureRecognizer!)
            } else {
                quicklookGestureRecognizer?.removeFromView()
                quicklookGestureRecognizer = nil
            }
        }
    }
    
    internal var quicklookGestureRecognizer: QuicklookGestureRecognizer? {
        get { getAssociatedValue(key: "quicklookGestureRecognizer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "quicklookGestureRecognizer", object: self) }
    }

    /**
     Opens `QuicklookPanel` that presents quicklook previews of the selected rows.
     */
    func quicklookSelectedRows() {
        quicklookRows(at: selectedRowIndexes.sorted())
    }

    /**
     Opens `QuicklookPanel` that presents quicklook previews for the rows at the specified indexes.
     - Parameter rowIndexes: The indexes of the rows.
     - Parameter current:
     */
    func quicklookRows(at rowIndexes: [Int], current: Int? = nil) {
        var previewables: [QuicklookPreviewable] = []
        var currentIndex = 0
        for row in rowIndexes {
            if let previewable = quicklookPreviewable(for: row) {
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
        (dataSource as? NSTableViewQuicklookProvider)?.tableView(self, quicklookPreviewForRow: row)
    }
}
