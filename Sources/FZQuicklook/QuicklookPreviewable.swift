//
//  QuicklookPreviewable.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import AppKit
import Quartz
import AVKit
import FZSwiftUtils

/**
 A protocol that defines a set of properties you implement to make a preview that can be displayed by `QuicklookPanel` and `QuicklookView`.
 
 `URL`, `NSURL` and `AVURLAsset` conform to QuicklookPreviewable.
 
 ```
 struct GalleryItem: QuicklookPreviewable {
 let title: String
 let imageURL: URL
 
 var previewItemURL: URL? {
    return imageURL
 }
 
 var previewItemTitle: String? {
    return title
 }
 }
 
 QuicklookPanel.shared.preset(aGalleryItem)
 ```
 */
public protocol QuicklookPreviewable {
    /**
     The URL of the item to preview.
     
     `QuicklookPanel` and `QuicklookView` use this property to get an item’s URL. In typical use, you’d implement a getter method in your preview item class to provide this value.
     
     The value of this property must be a file-type URL.
     
     If the item isn’t available for preview, this property’s getter method should return nil. In this case, the `QuicklookPanel` and `QuicklookView` displays a “loading” view. Use refreshCurrentPreviewItem() to reload the item once the URL content is available.
     */
    var previewItemURL: URL? { get }
    /**
     The item frame on the screen.
          
     The system invokes this optional property when the preview panel opens or closes to provide a zoom effect.
     
     `NSView` and `NSCollectionViewItem` conforming to `QuicklookPreviewable` provide their frame as default value.
     */
    var previewItemFrame: CGRect? { get }
    /**
     The transition image for the item.
          
     The system invokes this optional property when the preview panel opens or closes to provide a transition image.
     
     `NSView`, `NSCollectionViewItem` and `NSImageView` conforming to `QuicklookPreviewable` provide default values.
     */
    var previewItemTransitionImage: NSImage? { get }
    /**
     The title to display for the preview item.
     
     If you don’t implement this property, Quick Look examines the URL or content of the previewed item to determine an appropriate title. Return a non-nil value for this property to provide a custom title.
     */
    var previewItemTitle: String? { get }
}

extension QuicklookPreviewable {
    public var previewItemFrame: CGRect? {
        return nil
    }
    
    public var previewItemTransitionImage: NSImage? {
        return nil
    }
    
    public var previewItemTitle: String? {
        return previewItemURL?.deletingPathExtension().lastPathComponent
    }
}

extension URL: QuicklookPreviewable {
    public var previewItemURL: URL? {
        return self
    }
}

extension NSURL: QuicklookPreviewable {
    public var previewItemURL: URL? {
        return self as URL
    }
}

extension AVURLAsset: QuicklookPreviewable {
    public var previewItemURL: URL? {
        return url
    }
    
    public var previewItemTitle: String? {
        return url.deletingPathExtension().lastPathComponent
    }
}

extension QuicklookPreviewable where Self: NSImageView {
    public var previewItemFrame: CGRect? {
        return self.frameOnScreen
    }
    
    public var previewItemTransitionImage: NSImage? {
        self.image
    }
}

extension QuicklookPreviewable where Self: NSView {
    public var previewItemFrame: CGRect? {
        return self.frameOnScreen
    }
    
    public var previewItemTransitionImage: NSImage? {
        return self.renderedImage
    }
}

extension QuicklookPreviewable where Self: NSCollectionViewItem {
    public var previewItemFrame: CGRect? {
        self.view.frameOnScreen
    }
    
    public var previewItemTransitionImage: NSImage? {
        return self.view.renderedImage
    }
}
