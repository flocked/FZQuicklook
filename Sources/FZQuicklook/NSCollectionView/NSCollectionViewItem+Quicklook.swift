//
//  NSCollectionViewItem+Quicklook.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils

public extension NSCollectionViewItem {
    /**
     The quicklook preview for the item.

     To present the preview use `NSCollectionView` ``AppKit/NSCollectionView/quicklookSelectedItems()`` or ``AppKit/NSCollectionView/quicklookItems(at:current:)``.

     Make sure to reset it's value inside `prepareForReuse()`.
     */
    var quicklookPreview: QuicklookPreviewable? {
        get { getAssociatedValue("quicklookPreview", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "quicklookPreview")
            if newValue != nil {
                collectionView?.isQuicklookPreviewable = true
            }
        }
    }
}

/*
extension NSCollectionView {
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
        get { getAssociatedValue("quicklookGestureRecognizer", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "quicklookGestureRecognizer") }
    }
}
*/
