//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 24.11.2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ListSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "EMPTY_LIST_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "EMPTY_LIST_light")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error("This is a\nmulti-line\nerror message" ))
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyList() -> [CellController] {
        []
    }
}


