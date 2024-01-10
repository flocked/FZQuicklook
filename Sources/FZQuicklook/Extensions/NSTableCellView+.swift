//
//  NSTableCellView+.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit

extension NSTableCellView {
    /**
     The table view this cell is currently displaying.
     */
    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }
}
