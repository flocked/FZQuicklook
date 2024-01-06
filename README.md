# FZQuicklook

Create previews of files presented either in a panel similar to Finder's Quicklook or in a view.

**For a full documentation take a look at the** [Online Documentation](https://swiftpackageindex.com/flocked/FZQuicklook/documentation/).

## QuicklookPreviewable
 A protocol that defines a set of properties you implement to make a preview that can be displayed by `QuicklookPanel` and `QuicklookView`. `URL`, `NSURL` and `AVURLAsset` conform to QuicklookPreviewable.
 ```swift
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
NSCollectionView/NSTableView `isQuicklookPreviewable` enables quicklook of items/cells.

There are several ways to provide quicklook previews:
- NSCollectionViewItems's & NSTableCellView's `var quicklookPreview: QuicklookPreviewable?`
```
collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
```
- NSCollectionView's datasource `collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath)` & NSTableView's datasource `tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int)`
```
func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
    let galleryItem = galleryItems[indexPath.item]
    return galleryItem.fileURL
}
```
- A NSCollectionViewDiffableDataSource & NSTableViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`
```
struct GalleryItem: QuicklookPreviewable {
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
  
collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView) { 
collectionView, indexPath, galleryItem in
// configurate data source
}

// …
collectionView.quicklookSelectedItems()
```
