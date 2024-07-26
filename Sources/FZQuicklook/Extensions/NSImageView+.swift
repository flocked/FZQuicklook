//
//  NSImageView+.swift
//
//
//  Created by Florian Zand on 26.07.24.
//

import AppKit

extension NSImageView {    
    var imageBounds: CGRect {
        if let bounds = value(forKey: "_drawingRectForImage") as? CGRect {
            return bounds
        }
        
        guard let imageSize = image?.size else { return .zero }
    
        var contentFrame = CGRect(.zero, frame.size)
        switch imageFrameStyle {
        case .button, .groove:
            contentFrame = NSInsetRect(bounds, 2, 2)
        case .photo:
            contentFrame = CGRect(x: contentFrame.origin.x + 1, y: contentFrame.origin.x + 2, width: contentFrame.size.width - 3, height: contentFrame.size.height - 3)
        case .grayBezel:
            contentFrame = NSInsetRect(self.bounds, 8, 8)
        default:
            break
        }

        var drawingSize = imageSize
        switch imageScaling {
        case .scaleAxesIndependently:
            drawingSize = contentFrame.size
        case .scaleProportionallyUpOrDown:
            drawingSize = drawingSize.scaled(toFit: contentFrame.size)
        case .scaleProportionallyDown:
            drawingSize = drawingSize.scaled(toFit: contentFrame.size)
            if drawingSize.width > imageSize.width {
                drawingSize.width = imageSize.width
            }
            if drawingSize.height > imageSize.height {
                drawingSize.height = imageSize.height
            }
        default:
            if drawingSize.width > contentFrame.size.width { drawingSize.width = contentFrame.size.width }
            if drawingSize.height > contentFrame.size.height { drawingSize.height = contentFrame.size.height }
        }

        var drawingPosition = NSPoint(x: contentFrame.origin.x + contentFrame.size.width / 2 - drawingSize.width / 2,
                                      y: contentFrame.origin.y + contentFrame.size.height / 2 - drawingSize.height / 2)
        switch imageAlignment {
        case .alignTop:
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
        case .alignTopLeft:
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
            drawingPosition.x = contentFrame.origin.x
        case .alignTopRight:
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        case .alignLeft:
            drawingPosition.x = contentFrame.origin.x
        case .alignBottom:
            drawingPosition.y = contentFrame.origin.y
        case .alignBottomLeft:
            drawingPosition.y = contentFrame.origin.y
            drawingPosition.x = contentFrame.origin.x
        case .alignBottomRight:
            drawingPosition.y = contentFrame.origin.y
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        case .alignRight:
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        default:
            break
        }

        return CGRect(x: round(drawingPosition.x), y: round(drawingPosition.y), width: ceil(drawingSize.width), height: ceil(drawingSize.height))
      }
}
