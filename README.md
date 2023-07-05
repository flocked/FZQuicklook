# FZQuicklook


Create previews of files presented either in a panel similar to Finder's Quicklook or in a view.

## QuicklookPreviewable
 A protocol that defines a set of properties you implement to make a preview that can be displayed by `QuicklookPanel` and `QuicklookView`. `URL`, `NSURL` and `AVURLAsset` conform to QuicklookPreviewable.
 ```
 struct GalleryItem: QuicklookPreviewable {
 let title: String
 let imageURL: URL
 
 var previewItemURL: URL? {
    return imageURL
 }
 
 var previewItemTitle: String? {
    return title
 }
 }
 
 QuicklookPanel.shared.preset(aGalleryItem)
 ```

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

## Quicklook for NSTableView & NSCollectionView
`isQuicklookPreviewable` enables quicklook of NSCollectionView items and NSTableView cells/rows.

There are several ways to provide quicklook previews:
- NSCollectionViewItems's & NSTableCellView's `quicklookPreview`
```
collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
```
- NSCollectionView's datasource `collectionView(_:,  quicklookPreviewForItemAt:)` & NSTableView's datasource `tableView(_:,  quicklookPreviewForRow:)`
```
func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
    let galleryItem = galleryItems[indexPath.item]
    return galleryItem.fileURL
}
```
- A NSCollectionViewDiffableDataSource & NSTableViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`
```
struct GalleryItem: Hashable, QuicklookPreviewable {
    let title: String
    let imageURL: URL
    
    // The file url for quicklook preview.
    let previewItemURL: URL? {
    return imageURL
    }
    
    let previewItemTitle: String? {
    return title
    }
}
     
collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView) { collectionView, indexPath, galleryItem in
     
let collectionViewItem = collectionView.makeItem(withIdentifier: "FileCollectionViewItem", for: indexPath)
collectionViewItem.textField?.stringValue = galleryItem.title
collectionViewItem.imageView?.image = NSImage(contentsOf: galleryItem.imageURL)

return collectionViewItem
}
// …
collectionView.quicklookSelectedItems()
```
