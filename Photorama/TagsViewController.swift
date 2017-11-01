import UIKit
import CoreData

class TagsViewController: UITableViewController {
    var store: PhotoStore!
    var photo: Photo!
    
    var selectedIndexPaths = [IndexPath]()
    
    let tagDataSource = TagDataSource()
    
    
    @IBAction func done(sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewTag(sender: AnyObject) {
        let alertController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.placeholder = "tag name"
            textField.autocapitalizationType = .words
        })
        
        let okAction = UIAlertAction(title: "OK",
            style: .default,
            handler: { (action) -> Void in
                if let tagName = alertController.textFields?.first!.text {
                    let context = self.store.coreDateStack.mainQueueContext
                    let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)
                    newTag.setValue(tagName, forKey: "name")
                    
                    do {
                        try self.store.coreDateStack.saveChanges()
                    } catch let error {
                        print("Core Data save failed: \(error)")
                    }
                    self.updateTags()
                    self.tableView.reloadSections(IndexSet(integer:0), with: .automatic)
                }
            }
        )
        
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = tagDataSource
        tableView.delegate = self
        updateTags()
    }
    
    func updateTags() {
        let tags = try! store.fetchMainQueueTags(predicate: nil,
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        tagDataSource.tags = tags
        
        for tag in photo.tags {
            if let index = tagDataSource.tags.index(of: tag) {
                let indexPath = IndexPath(row: index, section: 0)
                selectedIndexPaths.append(indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tagDataSource.tags[indexPath.row]
        
        if let index = selectedIndexPaths.index(of: indexPath) {
            selectedIndexPaths.remove(at: index)
            photo.removeTagObject(tag: tag)
        } else {
            selectedIndexPaths.append(indexPath)
            photo.addTagObject(tag: tag)
        }
       
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        do {
            try store.coreDateStack.saveChanges()
        } catch let error {
            print("Core Data save failed: \(error)")
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedIndexPaths.index(of: indexPath) != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
}
