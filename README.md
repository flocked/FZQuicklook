# FZQuicklook

Create previews of content to be presented either in a panel similar to Finder's Quicklook or in a view.

It supports the preview of either a URL/NSURL to a file, NSImage, AVURLAsset, NSView, NSDocument or any object conforming to QLPreviewableContent.

## QuicklookPanel
Present files in a Quicklook panel simliar to Finder`s Quicklook. 
```
QuicklookPanel.shared.present(fileURLs)
```

## QuicklookView
 A Quick Look preview of an item that you can embed into your view hierarchy.
 
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
