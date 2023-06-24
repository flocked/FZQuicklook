//
//  File.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

public protocol DeletableCollectionViewDataSource: NSCollectionViewDataSource {
    func deleteItems(for indexPaths: Set<IndexPath>)
    var allowsDeleting: Bool { get }
}

public protocol DeletableTableViewDataSource: NSCollectionViewDataSource {
    func deleteItems(for indexPaths: Set<IndexPath>)
    var allowsDeleting: Bool { get }
}
