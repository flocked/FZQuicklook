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
     A Boolean value that indicates whether the user can quicklook preview selected items via pressing space bar.
     
     */
    var isQuicklookPreviewable: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isQuicklookPreviewable", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_isQuicklookPreviewable", object: self)
            if newValue == true {
                Self.swizzleCollectionViewResponderEvents()
            }
        }
    }
    
    func quicklookItems(at indexPaths: [IndexPath], current: IndexPath? = nil) {
        var previewables: [QuicklookPreviewable] = []
        var currentIndex = 0
        for indexPath in indexPaths {
            if let previewable = self.QuicklookPreviewable(for: indexPath) {
                previewables.append(previewable)
                if indexPath == current {
                    currentIndex = previewables.count - 1
                }
            }
        }
        
        QuicklookPanel.shared.keyDownResponder = self
        QuicklookPanel.shared.present(previewables, currentItemIndex: currentIndex)
    }

    func quicklookItems(_ items: [NSCollectionViewItem], current: NSCollectionViewItem? = nil) {
        let indexPaths = items.compactMap({self.indexPath(for: $0)})
        var currentIndexPath: IndexPath? = nil
        if let current = current {
            currentIndexPath = self.indexPath(for: current)
        }
        self.quicklookItems(at: indexPaths, current: currentIndexPath)
    }

    func quicklookSelectedItems() {
        Swift.print("quicklookSelectedItems")
        let selectedItems = selectionIndexPaths.compactMap { self.item(at: $0) }
        quicklookItems(selectedItems, current: selectedItems.first)
    }
    
    internal func QuicklookPreviewable(for indexPath: IndexPath) -> QuicklookPreviewable? {
        return (self.dataSource as? CollectionViewQLPreviewProvider)?.collectionView(self, quicklookPreviewForItemAt: indexPath)
    }
}
