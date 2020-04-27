//
//  ChangePasswordRequest.swift
//  EsCoachLogin
//
//  Created by nanashiki on 2020/04/16.
//

import Foundation
import APIModule

public struct ChangePasswordRequest: CoachAPIRequest {    
    public typealias Response = EmptyResponse
    public typealias RequestBody = EmptyRequestBody
    
    public var path = "change_password"
    public let method: HTTPMethod = .put

    
    public let authenticate: String?
    
    public init(currentPassword: String, newPassword: String, authenticate: String?) {
        self.authenticate = authenticate
    }
}
