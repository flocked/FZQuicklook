//
//  File.swift
//  
//
//  Created by Florian Zand on 25.05.23.
//

import AppKit

internal extension NSTableRowView {
    /**
     The array of cell views embedded in the current row.

     This array contains zero or more NSTableCellView objects that represent the cell views embedded in the current row view’s content.
     */
    var cellViews: [NSTableCellView] {
        (0 ..< numberOfColumns).compactMap { self.view(atColumn: $0) as? NSTableCellView }
        //    self.subviews.compactMap({$0 as? NSTableCellView})
    }
}
