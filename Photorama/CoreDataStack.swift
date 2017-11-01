import Foundation
import CoreData

class CoreDataStack {
    let managedObjectModelName: String
    
    lazy var mainQueueContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        moc.name = "Main Queue Context (UI Context)"
        
        return moc
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.managedObjectModelName, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        let url = self.applicationDocumentsDirectory.appendingPathComponent(pathComponent).absoluteURL
        
        let store = try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)

        return coordinator
    }()

    required init(modelName: String) {
        managedObjectModelName = modelName
    }
    
    func saveChanges() throws {
        var error: Error?
        mainQueueContext.performAndWait{
            if self.mainQueueContext.hasChanges {
                do {
                    try self.mainQueueContext.save()
                } catch let saveError {
                    error = saveError
                }
            }
        }

        if let aError = error {
            throw aError
        }
    }
}
