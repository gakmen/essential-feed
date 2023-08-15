//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 15.08.2023.
//

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOK: Bool { statusCode == HTTPURLResponse.OK_200 }
}
