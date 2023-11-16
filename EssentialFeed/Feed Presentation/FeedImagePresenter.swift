//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 07.08.2023.
//

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel (
            description: image.description,
            location: image.location
        )
    }
}
