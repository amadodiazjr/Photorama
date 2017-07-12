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
}
