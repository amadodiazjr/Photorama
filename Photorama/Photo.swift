import UIKit
import CoreData


public class Photo: NSManagedObject {
    var image: UIImage?

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Give the properties their initial values
        title = ""
        photoID = ""
        photoKey = UUID().uuidString
        dateTaken = Date()
    }
    
    func addTagObject(tag: NSManagedObject) {
        let currentTags = mutableSetValue(forKey: "tags")
        currentTags.add(tag)
    }
    
    func removeTagObject(tag: NSManagedObject) {
        let currentTags = mutableSetValue(forKey: "tags")
        currentTags.remove(tag)
    }
}
