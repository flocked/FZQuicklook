//
//  PreviewableDataSource.swift
//  
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils


public protocol CollectionViewQLPreviewProvider {
    func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable?
}

extension NSCollectionViewDiffableDataSource: CollectionViewQLPreviewProvider where ItemIdentifierType: QuicklookPreviewable {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let previewable = itemIdentifier(for: indexPath)  {
            return QuicklookPreviewItem(previewable, view: item.view)
        }
        return nil
    }
}

extension CollectionViewQLPreviewProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}

