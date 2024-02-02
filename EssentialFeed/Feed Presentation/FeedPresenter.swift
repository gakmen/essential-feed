//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 06.08.2023.
//

public final class FeedPresenter {
    
    public static var title: String {
        return NSLocalizedString (
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
}
