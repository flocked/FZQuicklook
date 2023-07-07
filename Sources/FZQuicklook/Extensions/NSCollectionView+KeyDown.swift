//
//  File.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

// Configurates a monitor for keyDown events on collection views with `isQuicklookPreviewable` enabled. A spacebar event will open the `QuicklookPanel`.
internal extension NSCollectionView {
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSCollectionView_keyDownMonitor", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_keyDownMonitor", object: self) }
    }
    
    var mouseDownMonitor: Any? {
        get { getAssociatedValue(key: "NSCollectionView_mouseDownMonitor", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_mouseDownMonitor", object: self) }
    }
    
    var selectionObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSCollectionView_selectionObserver_", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionView_selectionObserver_", object: self) }
    }
    
    func setupKeyDownMonitor() {
        if isQuicklookPreviewable {
            guard keyDownMonitor == nil else { return }
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                guard let self = self, self.window?.firstResponder == self else { return event }
                if self.isQuicklookPreviewable, event.keyCode == 49 {
                    if QuicklookPanel.shared.isVisible == false {
                        self.quicklookSelectedItems()
                    } else {
                        QuicklookPanel.shared.close()
                    }
                    return nil
                } else {
                    if QuicklookPanel.shared.isVisible {
                        let previousSelectionIndexPaths = self.selectionIndexPaths
                        self.keyDown(with: event)
                        if self.selectionIndexPaths != previousSelectionIndexPaths {
                            self.quicklookSelectedItems()
                        }
                        return nil
                    }
                }
                return event
            })
        } else if let keyDownMonitor = self.keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
    }
    
    func addSelectionObserver() {
        if self.selectionObserver == nil {
            self.selectionObserver = self.observeChanges(for: \.selectionIndexPaths, handler: { [weak self] old, new in
                guard let self = self else { return }
                if QuicklookPanel.shared.isVisible {
                    if old != new, new.isEmpty == false {
                        self.quicklookSelectedItems()
                    }
                } else {
                    removeSelectionObserver()
                }
            })
        }
    }
    
    func removeSelectionObserver() {
        self.selectionObserver?.invalidate()
        self.selectionObserver = nil
    }
    
    func setupMouseDownMonitor() {
        /*
        if isQuicklookPreviewable {
            guard mouseDownMonitor == nil else { return }
            mouseDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown, handler: { [weak self] event in
                guard let self = self else { return event }
                
                Swift.print("mouseMonitor window", event.window ?? "")
                /*
                if let window = event.window {
                    let previousSelectionIndexPaths = self.selectionIndexPaths
                    window.contentView?.mouseDown(with: event)
                    if self.selectionIndexPaths != previousSelectionIndexPaths {
                        self.quicklookSelectedItems()
                    }
                    return nil
                }
                */
                
                if let contentView = event.window?.contentView {
                    let location = event.location(in: contentView)
                    if let hitView = contentView.hitTest(location) {
                        Swift.print("mouseMonitor hitview", hitView)
                        let previousSelectionIndexPaths = self.selectionIndexPaths
                        hitView.mouseDown(with: event)
                        if self.selectionIndexPaths != previousSelectionIndexPaths {
                            self.quicklookSelectedItems()
                        }
                        return nil
                    }
                    
                }

                return event
            })
        } else if let mouseDownMonitor = self.mouseDownMonitor {
            NSEvent.removeMonitor(mouseDownMonitor)
            self.mouseDownMonitor = nil
        }
         */
    }
}
