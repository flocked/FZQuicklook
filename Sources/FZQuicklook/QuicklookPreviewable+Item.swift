//
//  QuicklookPreviewable+Item.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import QuickLookUI

/// An item used internally to preset items conforming to `QuicklookPreviewable` inside `QuicklookPanel` and `QuicklookView`.
class QuicklookPreviewItem: NSObject, QLPreviewItem, QuicklookPreviewable {
    let preview: QuicklookPreviewable
    weak var view: NSView?
    var id: String?

    var previewItemURL: URL? {
        preview.previewItemURL
    }

    var previewItemFrame: CGRect? {
        view?.frameOnScreen ?? preview.previewItemFrame
    }

    var previewItemTitle: String? {
        preview.previewItemTitle
    }

    var previewItemTransitionImage: NSImage? {
        view?.renderedImage ?? preview.previewItemTransitionImage
    }

    init(_ preview: QuicklookPreviewable, view: NSView? = nil, identifier: String? = nil) {
        self.preview = preview
        self.view = view
        self.id = identifier
    }
}
