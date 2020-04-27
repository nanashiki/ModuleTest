//
//  CoachAPIRequest.swift
//  EsCoach
//
//  Created by nanashiki on 2020/02/25.
//

import Foundation

public protocol CoachAPIRequest: Request {}

public extension CoachAPIRequest {
    var baseURL: URL {
        URL(string: "https://example.com/")!
    }
}
