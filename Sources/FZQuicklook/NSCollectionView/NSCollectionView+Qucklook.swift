//
//  NSCollectionView+Qucklook.swift
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
     - NSCollectionViewItems's ``AppKit/NSCollectionViewItem/quicklookPreview``
     ```swift
     collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
     // …
     collectionView.quicklookSelectedItems()
     ```
     - NSCollectionViewDataSource `collectionView(_:,  quicklookPreviewForItemAt:)`
     ```swift
     func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        let galleryItem = galleryItems[indexPath.item]
        return galleryItem.fileURL
     }
     ```
     - A `NSCollectionViewDiffableDataSource` with an ItemIdentifierType conforming to ``QuicklookPreviewable``
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

     collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView) { collectionView, indexPath, galleryItem in
        // Configurate collection view item
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

    /**
     Opens `QuicklookPanel` that presents quicklook previews for the items at the specified indexPaths.
     - Parameter indexPaths: The index paths the quicklook panel previews.
     - Parameter current:
     */
    func quicklookItems(at indexPaths: [IndexPath], current: IndexPath? = nil) {
        var previewables: [QuicklookPreviewable] = []
        var currentIndex = 0
        for indexPath in indexPaths {
            if let previewable = quicklookPreviewable(for: indexPath) {
                previewables.append(previewable)
                if indexPath == current {
                    currentIndex = previewables.count - 1
                }
            }
        }
        if QuicklookPanel.shared.isVisible == false {
            QuicklookPanel.shared.keyDownHandler = { [weak self] event in
                guard let self = self else { return }
                self.keyDown(with: event)
            }
            QuicklookPanel.shared.present(previewables, currentItemIndex: currentIndex)
            QuicklookPanel.shared.hidesOnAppDeactivate = true
        } else {
            QuicklookPanel.shared.items = previewables
            if currentIndex != QuicklookPanel.shared.currentItemIndex {
                QuicklookPanel.shared.currentItemIndex = currentIndex
            }
        }
    }

    /**
     Opens `QuicklookPanel` that presents quicklook previews of the selected items.
     */
    func quicklookSelectedItems() {
        guard selectionIndexPaths.isEmpty == false else { return }
        quicklookItems(at: Array(selectionIndexPaths).sorted())
    }

    internal func quicklookPreviewable(for indexPath: IndexPath) -> QuicklookPreviewable? {
        //   ((self.dataSource as? KeyValueCodable)?.call("quicklookPreviewForItemAt", values: [self, indexPath]) as? QuicklookPreviewable)
        (dataSource as? NSCollectionViewQuicklookProvider)?.collectionView(self, quicklookPreviewForItemAt: indexPath)
    }
}
