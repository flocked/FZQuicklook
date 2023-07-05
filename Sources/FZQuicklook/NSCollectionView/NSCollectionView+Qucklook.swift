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
     A Boolean value that indicates whether the user can quicklook preview selected items by pressing space bar.
     
     There are several ways to provide quicklook previews:
     - NSCollectionViewItems's `quicklookPreview`
     ```
     collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
     // …
     collectionView.quicklookSelectedItems()
     ```
     - NSCollectionView's datasource `collectionView(_:,  quicklookPreviewForItemAt:)`
     ```
     func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        let galleryItem = galleryItems[indexPath.item]
        return galleryItem.fileURL
     }
     ```
     - A NSCollectionViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`
     ```
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
          
     collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView) { collectionView, indexPath, galleryItem in
          
     let collectionViewItem = collectionView.makeItem(withIdentifier: "FileCollectionViewItem", for: indexPath)
     collectionViewItem.textField?.stringValue = galleryItem.title
     collectionViewItem.imageView?.image = NSImage(contentsOf: galleryItem.imageURL)

     return collectionViewItem
     }
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
        //    QuicklookPanel.shared.keyDownResponder = self
            QuicklookPanel.shared.present(previewables, currentItemIndex: currentIndex)
            QuicklookPanel.shared.hidesOnAppDeactivate = true
        } else {
            QuicklookPanel.shared.items = previewables
            if currentIndex != QuicklookPanel.shared.currentItemIndex {
                QuicklookPanel.shared.currentItemIndex = currentIndex
            }
        }
        QuicklookPanel.shared.panelDidCloseHandler = { [weak self] in
            guard let self = self else { return }
            self.removeSelectionObserver()
        }
        self.addSelectionObserver()
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
