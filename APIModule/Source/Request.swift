//
//  Request.swift
//  EsCoach
//
//  Created by nanashiki on 2020/02/25.
//

import Foundation

// swiftlint:disable line_length

public protocol Request {
    associatedtype Response: Decodable, Equatable
    associatedtype RequestBody: Encodable

    var baseURL: URL { get }

    var method: HTTPMethod { get }

    var path: String { get }

    var queryParameters: [String: Any]? { get }

    var requestBody: RequestBody { get }
    
    var authenticate: String? { get }
    
    // ここをコメントアウトするとうまく行く
//    func decode(data: Data) throws -> Response
}

public struct EmptyRequestBody: Encodable {
    public init() {}
}
public struct EmptyResponse: Decodable, Equatable {
    public init() {}
}

public extension Request where RequestBody == EmptyRequestBody {
    var requestBody: RequestBody { EmptyRequestBody() }
}

public extension Request {
    var headerFields: [String: String]? {
        var header = ["Content-Type": "application/json"]
        
        if let authenticate = authenticate {
            header["Authorization"] = authenticate
        }
        
        return header
    }

    var queryParameters: [String: Any]? { nil }
}

public extension Request where Response == EmptyResponse {
    func decode(data: Data) throws -> Response {
        return EmptyResponse()
    }
}

public extension Request {
    func decode(data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return try decoder.decode(Response.self, from: data)
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}
