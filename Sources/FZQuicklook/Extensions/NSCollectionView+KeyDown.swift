//
//  NSCollectionView+KeyDown.swift
//
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit
import FZSwiftUtils

// Configurates a monitor for keyDown events on collection views with `isQuicklookPreviewable` enabled. A spacebar event will open the `QuicklookPanel`.
extension NSCollectionView {
    var keyDownMonitor: Any? {
        get { getAssociatedValue("NSCollectionView_keyDownMonitor", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "NSCollectionView_keyDownMonitor") }
    }

    var mouseDownMonitor: Any? {
        get { getAssociatedValue("NSCollectionView_mouseDownMonitor", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "NSCollectionView_mouseDownMonitor") }
    }

    var selectionObserver: KeyValueObservation? {
        get { getAssociatedValue("NSCollectionView_selectionObserver_", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "NSCollectionView_selectionObserver_") }
    }

    func setupKeyDownMonitor() {
        if isQuicklookPreviewable {
            guard keyDownMonitor == nil else { return }
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                guard let self = self, self.window?.firstResponder == self else { return event }
                if self.isQuicklookPreviewable, event.keyCode == 49 {
                    if QuicklookPanel.shared.isVisible == false {
                        self.quicklookSelectedItems()
                        QuicklookPanel.shared.keyDownHandler = { [weak self] event in
                            guard let self = self else { return }
                            self.keyDown(with: event)
                        }
                    } else {
                        QuicklookPanel.shared.close()
                    }
                    return nil
                }
                return event
            })
        } else if let keyDownMonitor = keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
    }

    func addSelectionObserver() {
        if selectionObserver == nil {
            selectionObserver = observeChanges(for: \.selectionIndexPaths, handler: { [weak self] old, new in
                guard let self = self else { return }
                if QuicklookPanel.shared.isVisible {
                    guard old != new else { return }
                    self.quicklookSelectedItems()
                } else {
                    removeSelectionObserver()
                }
            })
        }
    }

    func removeSelectionObserver() {
        selectionObserver?.invalidate()
        selectionObserver = nil
    }

    func setupMouseDownMonitor() {
        /*
         if isQuicklookPreviewable {
             guard mouseDownMonitor == nil else { return }
             mouseDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown, handler: { [weak self] event in
                 guard let self = self else { return event }

                 Swift.debugPrint("mouseMonitor window", event.window ?? "")
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
                         Swift.debugPrint("mouseMonitor hitview", hitView)
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
