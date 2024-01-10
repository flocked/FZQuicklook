//
//  NSCollectionViewItem+Quicklook.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils

public extension NSCollectionViewItem {
    /**
     The quicklook preview for the item.

     To present the preview use `NSCollectionView` ``AppKit/NSCollectionView/quicklookSelectedItems()`` or ``AppKit/NSCollectionView/quicklookItems(at:current:)``.

     Make sure to reset it's value inside `prepareForReuse()`.
     */
    var quicklookPreview: QuicklookPreviewable? {
        get { getAssociatedValue(key: "quicklookPreview", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "quicklookPreview", object: self)
            if newValue != nil {
                collectionView?.isQuicklookPreviewable = true
            }
        }
    }
}
