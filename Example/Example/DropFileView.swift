//
//  DropFileView.swift
//  Example
//
//  Created by Florian Zand on 12.01.24.
//

import Cocoa

class DropFileView: NSView {
    
    var filesDroppedHandler: (([URL])->())? = nil
    var allowsMultipleFiles: Bool = true

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return filesOnPasteboard(for: sender) != nil && filesDroppedHandler != nil
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard let files = self.filesOnPasteboard(for: sender) else {
            return []
        }
        if !self.allowsMultipleFiles, files.count != 1 {
            return []
        }
        
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let filesDroppedHandler = self.filesDroppedHandler, let files = self.filesOnPasteboard(for: sender) else { return false }
        filesDroppedHandler(files)
        return true
    }
    
    private func filesOnPasteboard(for sender: NSDraggingInfo) -> [URL]? {
        let pb = sender.draggingPasteboard
        guard let objs = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] else {
            return nil
        }

        let urls = objs.compactMap { $0 as URL }
        return urls.count == 0 ? nil : urls
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
        registerForDraggedTypes([.fileURL])
    }
}
