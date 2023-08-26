//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 28.05.2023.
//

import CoreData

internal extension NSPersistentContainer {
    
    static func load (
        name: String,
        model: NSManagedObjectModel,
        url: URL
    ) throws -> NSPersistentContainer {
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
