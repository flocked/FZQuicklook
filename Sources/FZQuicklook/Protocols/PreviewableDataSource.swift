//
//  PreviewableDataSource.swift
//  
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

public protocol PreviewableDataSource {
    func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable?
}

extension PreviewableDataSource {
    func qlPreviewable(for indexPaths: [IndexPath]) -> [QLPreviewable] {
        indexPaths.compactMap { self.qlPreviewable(for: $0) }
    }
}

extension NSCollectionViewDiffableDataSource: PreviewableDataSource where ItemIdentifierType: QLPreviewable {
    public func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        itemIdentifier(for: indexPath)
    }
}

@available(macOS 11.0, *)
extension NSTableViewDiffableDataSource: PreviewableDataSource where ItemIdentifierType: QLPreviewable {
    public func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        itemIdentifier(forRow: indexPath.item)
    }
}

