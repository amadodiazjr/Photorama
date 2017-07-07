import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!

    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self

        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            OperationQueue.main.addOperation {
                switch photosResult {
                    case let .Success(photos):
                        print("Successfully found \(photos.count) recent photos.")
                        self.photoDataSource.photos = photos
                    case let .Failure(error):
                        self.photoDataSource.photos.removeAll()
                        print("Error fetching recent photos: \(error)")
                }

                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        // Download the image data, which could take some time
        store.fetchImageForPhoto(photo: photo) {(result) -> Void in
            OperationQueue.main.addOperation {
                // The index path for the photo might have changed between the
                // time the request started and finished, so find the post recent
                // index path

                // (Note: You will have an error on the next line; you will fix it soon)
                let photoIndex = self.photoDataSource.photos.index(of: photo)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)

                // When the request finishes, only update the cell if it's still visible
                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(image: photo.image)
                }
            }
        }
    }
}
