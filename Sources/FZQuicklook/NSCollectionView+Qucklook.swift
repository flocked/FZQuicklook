//
//  NSCollectionView+QLPreviewable.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSCollectionView {
    var quicklookSelectedItemsEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_quicklookSelectedItemsEnabled", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_quicklookSelectedItemsEnabled", object: self)
            if newValue == true {
                Self.swizzleCollectionViewResponderEvents()
            }
        }
    }
    
    func quicklookItems(at indexPaths: [IndexPath], current: IndexPath? = nil) {
        var previewables: [QLPreviewable] = []
        var currentIndex = 0
        for indexPath in indexPaths {
            if let previewable = self.qlPreviewable(for: indexPath) {
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
    
    internal func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        if let dataSource = self.dataSource as? (PreviewableDataSource & NSCollectionViewDataSource) {
            return dataSource.qlPreviewable(for: indexPath)
        } else if let dataSource = self.dataSource {
            return dataSource.collectionView(self, itemForRepresentedObjectAt: indexPath) as? QLPreviewable
        }
        return nil
    }
}

#endif
