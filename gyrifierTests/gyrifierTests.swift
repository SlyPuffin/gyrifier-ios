//
//  gyrifierTests.swift
//  gyrifierTests
//
//  Created by   on 2/23/23.
//

import XCTest
import CoreData
import SwiftUI
@testable import gyrifier

final class gyrifierTests: XCTestCase {
    
    private var reviewViewModel = ReviewViewModel()

    override func setUpWithError() throws {
//        let managedObjectContext = setUpInMemoryManagedObjectContext()
//        seedCards(context: managedObjectContext)
//
//        let fetchRequest = NSFetchRequest<Card>(entityName: "Card")
//        do {
//            let cards = try managedObjectContext.fetch(fetchRequest)
//            XCTAssertTrue(cards.count == 3, "There should have been 3 Card objects inserted by seedCards()")
//        } catch _ {}

        // Put setup code here. This method is called before the invocation of each test method in the class.
        //reviewViewModel.prepareCards(cards: cards.filter({isStudyDateToday($0.nextAppearance!)}).shuffled())
        //reviewViewModel.startTimer()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let reviewTime = ReviewTime.five("5 min", 300.0)
        XCTAssertEqual(reviewTime, ReviewTime.five("5 min", 300.0))
    }
    
    func testReviewViewModel() throws {
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        seedCardsLateAppearance(context: managedObjectContext)

        var fetchRequest = NSFetchRequest<Card>(entityName: "Card")
        var cards: [Card] = []
        do {
            cards = try managedObjectContext.fetch(fetchRequest)
            XCTAssertTrue(cards.count == 3, "There should have been 3 Card objects inserted by seedCards()")
        } catch _ {}
        
        reviewViewModel.prepareCards(cards: cards)
        XCTAssertTrue(reviewViewModel.isFinished, "Review should have finished due to cards filtering to 0")
        XCTAssertTrue(reviewViewModel.isLoading, "Loading should still be in place as no cards are in array")
        
        seedCards(context: managedObjectContext)
        fetchRequest = NSFetchRequest<Card>(entityName: "Card")
        do {
            cards = try managedObjectContext.fetch(fetchRequest)
            XCTAssertTrue(cards.count == 7, "There should have been 7 Card objects inserted by seedCards()")
        } catch _ {}
        
        reviewViewModel = ReviewViewModel()
        reviewViewModel.prepareCards(cards: cards)
        XCTAssertFalse(reviewViewModel.isFinished, "Review should not be finished as there are cards to review")
        XCTAssertFalse(reviewViewModel.isLoading, "Review should have started so no cards are loading")
        
        reviewViewModel.startTimer()

        XCTAssertEqual(reviewViewModel.currentCard.category, "Now", "Category should be 'Now' due to filtering")
        reviewViewModel.iterateCards(viewContext: managedObjectContext)
        XCTAssertEqual(reviewViewModel.currentCard.category, "Now", "Category should be 'Now' due to filtering")
        XCTAssertFalse(reviewViewModel.isFinished, "Review should not be finished as there should be two more cards")
        reviewViewModel.iterateCards(viewContext: managedObjectContext)
        XCTAssertEqual(reviewViewModel.currentCard.category, "Now", "Category should be 'Now' due to filtering")
        XCTAssertFalse(reviewViewModel.isFinished, "Review should not be finished as there should be one last card")
        reviewViewModel.iterateCards(viewContext: managedObjectContext)
        XCTAssertTrue(reviewViewModel.isFinished, "Review should have finished due to all cards iterating")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
