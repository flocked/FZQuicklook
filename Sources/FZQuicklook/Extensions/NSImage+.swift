//
//  File.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

import AppKit

internal extension NSBitmapImageRep {
    var jpegData: Data? { representation(using: .jpeg, properties: [:]) }
    var pngData: Data? { representation(using: .png, properties: [:]) }
    var tiffData: Data? { representation(using: .tiff, properties: [:]) }
}

internal extension NSImage {
    var cgImage: CGImage? {
        guard let imageData = tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
    
    var bitmapImageRep: NSBitmapImageRep? {
        if let cgImage = cgImage {
            let imageRep = NSBitmapImageRep(cgImage: cgImage)
            imageRep.size = size
            return imageRep
        }
        return nil
    }
    
    var tiffData: Data? { tiffRepresentation }
    var pngData: Data? { bitmapImageRep?.pngData }
    var jpegData: Data? { bitmapImageRep?.jpegData }
}
