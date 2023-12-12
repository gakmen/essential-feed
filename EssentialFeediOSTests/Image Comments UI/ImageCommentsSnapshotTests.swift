//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 24.11.2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "IMAGE_COMMENTS_light")
        
        assert (
            snapshot: sut.snapshot(for: .iPhone14(style: .dark, contentSize: .extraExtraExtraLarge)),
            named: "IMAGE_COMMENTS_dark_extraExtraExtraLarge"
        )
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func comments() -> [CellController] {
        commentControllers().map { CellController(id: UUID(), $0) }
    }
    
    private func commentControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController (
                model: ImageCommentViewModel (
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController (
                model: ImageCommentViewModel (
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1",
                    date: "100 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController (
                model: ImageCommentViewModel (
                    message: "The East",
                    date: "5 minutes ago",
                    username: "a."
                )
            )
        ]
    }
}
