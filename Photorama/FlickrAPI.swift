import CoreData
import Foundation

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(Error)
}

enum FlickrError: Error {
    case InvalidJSONData
}

struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        let components = NSURLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    private static func photoFromJSONObject(json: [String: Any],
                                            inContext context: NSManagedObjectContext) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                // Don't have enough information to construct a Photo
                return nil
        }
        
        var photo: Photo!
        context.performAndWait() {
            photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url
            photo.dateTaken = dateTaken
        }
        
        return photo
    }

    static func recentPhotosURL() -> URL {
        return flickrURL(method: .RecentPhotos, parameters: ["extras":"url_h,date_taken"])
    }
    
    static func photosFromJSONData(data: Data, inContext context: NSManagedObjectContext) -> PhotosResult {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])

            guard let
            jsonDictionary = jsonObject as? [String:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]] else {
                    // The JSON structure doesn't match  our expectations
                    return .Failure(FlickrError.InvalidJSONData)
            }

            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(json: photoJSON, inContext: context) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                // We weren't able to parse any of the photos
                // Maybe the JSON format for photos has changed
                return .Failure(FlickrError.InvalidJSONData)
            }

            return .Success(finalPhotos)
        } catch let error {
            return .Failure(error)
        }
    }
}
