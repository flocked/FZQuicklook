//
//  PreviewableDataSource.swift
//  
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

public protocol NSCollectionViewQuicklookProvider {
    /**
     Asks your data source object for the quicklook preview that corresponds to the specified item in the collection view.
     
     */
    func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable?
}

extension NSCollectionViewDiffableDataSource: NSCollectionViewQuicklookProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let previewable = itemIdentifier(for: indexPath) as? QuicklookPreviewable {
            return QuicklookPreviewItem(previewable, view: item.view)
        }
        return nil
    }
}

extension NSCollectionViewQuicklookProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}

