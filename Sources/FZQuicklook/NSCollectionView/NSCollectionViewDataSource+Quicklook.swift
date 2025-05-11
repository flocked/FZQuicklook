//
//  NSCollectionViewDataSource+Quicklook.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

/// A `NSCollectionView` Quicklook preview provider.
public protocol NSCollectionViewQuicklookProvider {
    /**
     Asks your data source object for a quicklook preview that corresponds to the specified item in the collection view.
     */
    func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable?
}

public extension NSCollectionViewQuicklookProvider {
    /**
     Asks your data source object for a quicklook preview that corresponds to the specified item in the collection view.
     */
    func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}

@available(macOS 10.15.1, *)
extension NSCollectionViewDiffableDataSource: NSCollectionViewQuicklookProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let previewable = itemIdentifier(for: indexPath) as? QuicklookPreviewable {
            return QuicklookPreviewItem(previewable, view: item.view)
        } else if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}
