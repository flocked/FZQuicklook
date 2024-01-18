//
//  ViewController.swift
//  Example
//
//  Created by Florian Zand on 11.01.24.
//

import Cocoa
import FZQuicklook
import FZSwiftUtils

class ViewController: NSViewController {

    @IBOutlet weak var quicklookView1: QuicklookView!
    @IBOutlet weak var quicklookView2: QuicklookView!
    @IBOutlet weak var quicklookView3: QuicklookView!
    @IBOutlet weak var quicklookView4: QuicklookView!
    
    lazy var quicklookViews: [QuicklookView] = {
        [quicklookView1, quicklookView2, quicklookView3, quicklookView4]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    let dropFileView = DropFileView(frame: .zero)
    let quicklookView = QuicklookView()
    var keyDownMonitor: Any? = nil
    var previewIndex = 0
    var previewURLs: [URL] = []
    override func viewDidAppear() {
        super.viewDidAppear()
        quicklookView1.style = .compact
        quicklookView2.style = .compact
        quicklookView3.style = .compact
        quicklookView4.style = .compact
        
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 49 {
                if QuicklookPanel.shared.isVisible == false, self.previewURLs.isEmpty == false {
                  //  QuicklookPanel.shared.keyDownResponder
                    QuicklookPanel.shared.currentItemHandler = { item, index in
                        self.resetBorderWidth(for: self.previewIndex)
                        self.quicklookViews[safe: index]?.borderWidth = 2.0
                        self.quicklookViews[safe: index]?.borderColor = .controlAccentColor
                        self.previewIndex = index
                    }
                    QuicklookPanel.shared.present(self.quicklookViews, currentItemIndex: self.previewIndex)
                }
            }
            Swift.print(event.keyCode)
            return event
            
        }

        quicklookView.frame.size = view.bounds.size
        dropFileView.frame.size = view.bounds.size
        dropFileView.filesDroppedHandler = { files in
            self.previewURLs = files
            self.previewIndex = 0
            self.quicklookView1.item = files[safe: 0]
            self.quicklookView2.item = files[safe: 1]
            self.quicklookView3.item = files[safe: 2]
            self.quicklookView4.item = files[safe: 3]
        }
        self.quicklookView1.wantsLayer = true
        self.quicklookView2.wantsLayer = true
        self.quicklookView3.wantsLayer = true
        self.quicklookView4.wantsLayer = true

        view.addSubview(dropFileView)
    }
    
    func resetBorderWidths() {
        quicklookViews.forEach({$0.borderWidth = 0.0})
    }
    func resetBorderWidth(for index: Int) {
        quicklookViews[safe: index]?.borderWidth = 0.0
    }
}

