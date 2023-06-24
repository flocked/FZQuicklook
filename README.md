# FZQuicklook


Create previews of files presented either in a panel similar to Finder's Quicklook or in a view.

## QuicklookPanel
Presents previews of files in a panel simliar to Finder`s Quicklook. 
```
QuicklookPanel.shared.present(fileURLs)
```

## QuicklookView
 A preview of a file that you can embed into your view hierarchy.
 
```
let quicklookView = QuicklookView(content: URL(fileURLWithPath: imageFileURL)
```

## Quicklook NSTableView & NSCollectionView
- NSTableViewDataSource
```
func tableView(tableView: NSTableView, quicklookPreviewForRow row: Int) -> QLPreviewable? {
    let item = items[row]
    return QuicklookItem(content: item.fileURL)
}

// …
tableView.quicklookSelectedRows()
```

- NSCollectionViewDataSource
```
func collectionView(collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QLPreviewable? {
    let item = items[indexPath.item]
    return QuicklookItem(content: item.fileURL)
}

// …
collectionView.quicklookSelectedItems()

```

- When NSTableView/NScollectionView quicklookSelectedItemsEnabled is true, 

If a NSCollectionViewItem/NSTableCellView conforms to QLPreviable, it also provides easy quicklock of selected items/cells.
```
class CustomCollectionItem: NSCollectionItem, QLPreviable {
    var fileURL: URL?
    var previewContent: QLPreviableContent? {
        return fileURL
    }
}

collectionView.quicklookSelectedItems()
```
