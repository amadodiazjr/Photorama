import UIKit
import CoreData

class TagsViewController: UITableViewController {
    var store: PhotoStore!
    var photo: Photo!
    
    var selectedIndexPaths = [NSIndexPath]()
    
    let tagDataSource = TagDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = tagDataSource
        
        updateTags()
    }
    
    func updateTags() {
        let tags = try! store.fetchMainQueueTags(predicate: nil,
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        //tagDataSource.tags = tags
    }
}
