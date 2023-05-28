//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 22.05.2023.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion (.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.createNewUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.getImages(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform{ action(context) }
    }
    
    @objc(ManagedCache)
    private class ManagedCache: NSManagedObject {
        @NSManaged var timestamp: Date
        @NSManaged var feed: NSOrderedSet
        
        var localFeed: [LocalFeedImage] {
            return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
        }
        
        static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            let cache = try context.fetch(request).first
            return cache
        }
        
        static func createNewUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
            try find(in: context).map(context.delete)
            return ManagedCache(context: context)
        }
    }
    
    @objc(ManagedFeedImage)
    private class ManagedFeedImage: NSManagedObject {
        @NSManaged var id: UUID
        @NSManaged var imageDescription: String?
        @NSManaged var location: String?
        @NSManaged var url: URL
        @NSManaged var cache: ManagedCache
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
        }
        
        static func getImages(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
            return NSOrderedSet (
                array: localFeed.map { local in
                    let managed = ManagedFeedImage(context: context)
                    managed.id = local.id
                    managed.imageDescription = local.description
                    managed.location = local.location
                    managed.url = local.url
                    return managed
                }
            )
        }
    }
}
