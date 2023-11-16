//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 16.11.2023.
//

public final class ImageCommentsPresenter {
    
    public static var title: String {
        return NSLocalizedString (
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the image comments view"
        )
    }
}
