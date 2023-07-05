//
//  QuicklookPreviewItem.swift
//  QuicklookNew
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import QuickLookUI

/// An item used internally to preset items conforming to `QuicklookPreviewable` inside `QuicklookPanel` and `QuicklookView`.
internal class QuicklookPreviewItem: NSObject, QLPreviewItem, QuicklookPreviewable {
    let preview: QuicklookPreviewable
    var view: NSView?
    
    public var previewItemURL: URL? {
        preview.previewItemURL
    }
    public var previewItemFrame: CGRect? {
        view?.frameOnScreen ?? preview.previewItemFrame
    }
    public var previewItemTitle: String? {
        preview.previewItemTitle
    }
    public var previewItemTransitionImage: NSImage? {
        view?.renderedImage ?? preview.previewItemTransitionImage
    }
    
    internal init(_ preview: QuicklookPreviewable, view: NSView? = nil) {
        self.preview = preview
        self.view = view
    }
}
