//
//  coreDataTestHelpers.swift
//  gyrifierTests
//
//  Created by   on 3/23/23.
//

import Foundation
import CoreData
import gyrifier

let ThreeCardFilteredArray = [
    (cardFront: "Front 1", cardBack: "Back 1", category: "Future", nextAppearance: Date(timeIntervalSinceNow: 24.0 * 60.0 * 60.0)),
    (cardFront: "Front 2", cardBack: "Back 2", category: "Now", nextAppearance: Date()),
    (cardFront: "Front 3", cardBack: "Back 3", category: "Now", nextAppearance: Date(timeIntervalSinceNow: -24.0 * 60.0 * 60.0)),
    (cardFront: "Front 4", cardBack: "Back 4", category: "Now", nextAppearance: Date(timeIntervalSinceNow: 5.0 * 60.0))
]

let EmptyFilteredArray = [
    (cardFront: "Front 1", cardBack: "Back 1", category: "Future", nextAppearance: Date(timeIntervalSinceNow: 24.0 * 60.0 * 60.0)),
    (cardFront: "Front 2", cardBack: "Back 2", category: "Future", nextAppearance: Date(timeIntervalSinceNow: 24.0 * 60.0 * 60.0)),
    (cardFront: "Front 3", cardBack: "Back 3", category: "Future", nextAppearance: Date(timeIntervalSinceNow: 24.0 * 60.0 * 60.0))
]


func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!

    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
        print("Adding in-memory persistent store failed")
    }

    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

    return managedObjectContext
}

func seedCards(context: NSManagedObjectContext, cards: [(cardFront: String, cardBack: String, category: String, nextAppearance: Date)]) {
    
    for card in cards {
        let newCard = NSEntityDescription.insertNewObject(forEntityName: "Card", into: context) as! Card
        newCard.cardFront = card.cardFront
        newCard.cardBack = card.cardBack
        newCard.nextAppearance = card.nextAppearance
        newCard.category = card.category
    }

    do {
        try context.save()
    } catch _ {
    }
}

func fetchCards(context: NSManagedObjectContext) -> [Card] {
    let fetchRequest = NSFetchRequest<Card>(entityName: "Card")
    var result: [Card] = []
    do {
        result = try context.fetch(fetchRequest)
    } catch _ {}
    
    return result
}
