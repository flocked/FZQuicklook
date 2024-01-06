//
//  QuicklookItem.swift
//  
//
//  Created by Florian Zand on 06.03.23.
//

import AppKit
import QuickLookUI

/**
 An item that is previewable by `QuicklookPanel` and `QuicklookView`.
 */
open class QuicklookItem: QuicklookPreviewable {
     /**
     The URL of the item to preview.
     
     QLPreviewController uses this property to get an item’s URL. In typical use, you’d implement a getter method in your preview item class to provide this value.
     
     The value of this property must be a file-type URL.
     
     If the item isn’t available for preview, this property’s getter method should return nil. In this case, the `QuicklookPanel` displays a “loading” view. Use refreshCurrentPreviewItem() to reload the item once the URL content is available.
     */
    open var previewItemURL: URL?
    /**
     The item frame on the screen.
          
     The system invokes this optional property when the preview panel opens or closes to provide a zoom effect.
     */
    open var previewItemFrame: CGRect?
    /**
     The transition image for the item.
          
     The system invokes this optional property when the preview panel opens or closes to provide a transition image.
     */
    open var previewItemTransitionImage: NSImage?
    /**
     The title to display for the preview item.
     */
    open var previewItemTitle: String?

    public init(url: URL, frame: CGRect? = nil, title: String? = nil, transitionImage: NSImage? = nil) {
        self.previewItemURL = url
        self.previewItemFrame = frame
        self.previewItemTitle = title
        self.previewItemTransitionImage = transitionImage
    }
}

/*
extension QuicklookItem: Hashable {
    public static func == (lhs: QuicklookItem, rhs: QuicklookItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(previewItemURL)
        hasher.combine(previewItemFrame)
        hasher.combine(previewItemTitle)
        hasher.combine(previewItemTransitionImage)
    }
}
*/
