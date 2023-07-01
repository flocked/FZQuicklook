//
//  NSCollectionView+QuicklookPreviewable.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import AppKit
import FZSwiftUtils

public extension NSCollectionView {
    /**
     A Boolean value that indicates whether the user can quicklook preview selected items via space bar.
     
     There are several ways to provide quicklook previews:
     - NSCollectionViewItems's `quicklookPreview`:
     ```
     collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
     ```
     - NSCollectionView's datasource `tableView(_:,  quicklookPreviewForRow:)`:
     ```
     func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        let item = collectionItems[indexPath.item]
        return item.fileURL
     }

     ```
     - A NSCollectionViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`:
     ```
     struct FileItem: Hashable, QuicklookPreviewable {
        let title: String
        let image: NSImage
        let previewItemURL: URL?
     }
     
    collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, FileItem>(collectionView: collectionView) { collectionView, indexPath, fileItem in
     
        let collectionViewItem = collectionView.makeItem(withIdentifier: "FileCollectionViewItem", for: indexPath)
        collectionViewItem.textField?.stringValue = fileItem.title
        collectionViewItem.imageView?.image = fileItem.image

        return collectionViewItem
    }
     // …
     collectionView.quicklookSelectedItems()
     ```
     */
    var isQuicklookPreviewable: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isQuicklookPreviewable", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_isQuicklookPreviewable", object: self)
            self.setupKeyDownMonitor()
        }
    }
    
    /**
     Opens `QuicklookPanel` that presents quicklook previews for the items at the specified indexPaths.
     - Parameters indexPaths: The index paths the quicklook panel previews.
     - Parameters current: 
     */
    func quicklookItems(at indexPaths: Set<IndexPath>, current: IndexPath? = nil) {
        var previewables: [QuicklookPreviewable] = []
        var currentIndex = 0
        for indexPath in indexPaths {
            if let previewable = self.quicklookPreviewable(for: indexPath) {
                previewables.append(previewable)
                if indexPath == current {
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
        self.setupMouseDownMonitor()
    }
    
    /**
     Opens `QuicklookPanel` that presents quicklook previews of the selected items.
     */
    func quicklookSelectedItems() {
        guard selectionIndexPaths.isEmpty == false else { return }
        quicklookItems(at: selectionIndexPaths)
    }
    
    internal func quicklookPreviewable(for indexPath: IndexPath) -> QuicklookPreviewable? {
        return (self.dataSource as? NSCollectionViewQuicklookProvider)?.collectionView(self, quicklookPreviewForItemAt: indexPath)
    }
}
