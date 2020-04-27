//
//  APIClient.swift
//  EsCoach
//
//  Created by nanashiki on 2020/02/27.
//

import Combine
import Foundation

struct TestRequest: CoachAPIRequest {
    

    typealias Response = EmptyResponse
    typealias RequestBody = EmptyRequestBody

//    var path = "/set_permanent_password"
//    let method: HTTPMethod = .post
    
    
    var path = "change_password"
    
    var method: HTTPMethod = .put
    
    let requestBody: RequestBody
    
    let authenticate: String?
    
    init(currentPassword: String, newPassword: String, authenticate: String?) {
        self.authenticate = authenticate
        requestBody = EmptyRequestBody()
    }
}


enum HTTPError: LocalizedError {
    case statusCode(_ code: Int)
    case unknown
}

public protocol APIClient {
    func send<R: Request>(request: R) -> AnyPublisher<R.Response, Error>
}

public struct APIClientImpl: APIClient {
    private let session: URLSession

    public init() {
        session = URLSession.shared
    }

    public func send<R: Request>(request: R) -> AnyPublisher<R.Response, Error> {
        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
        
        print(R.Response.self)
        let data = try? request.decode(data: "".data(using: .utf8)!)
        print(data)
        
        let data2 = try? TestRequest(currentPassword: "", newPassword: "", authenticate: nil).decode(data: "".data(using: .utf8)!)
        print(data2)

        return session
            .dataTaskPublisher(for: urlRequest)
            .tryMap({ (output) -> (data: Data, response: URLResponse) in
                guard let response = output.response as? HTTPURLResponse else {
                    throw HTTPError.unknown
                }
                guard (200..<300).contains(response.statusCode) else {
                    self.logError(request: urlRequest, statusCode: response.statusCode)
                    throw HTTPError.statusCode(response.statusCode)
                }
                return output
            })
            .map { $0.data }
            .handleEvents(
                receiveOutput: { self.log(request: urlRequest, response: String(data: $0, encoding: .utf8) ?? "") }
            )
            .tryMap { try request.decode(data: $0) }
            .eraseToAnyPublisher()
    }

    private func log(request: URLRequest, response: Any) {
        #if DEBUG
            print("")
            print("200 \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
            print("  requestHeader: \(request.allHTTPHeaderFields ?? [:])")
            if let httpBody = request.httpBody {
                print("  requestBody: \(String(data: httpBody, encoding: .utf8) ?? "")")
            }
            print("  response: \(response)")
            print("")
        #endif
    }
    
    private func logError(request: URLRequest, statusCode: Int) {
        #if DEBUG
            print("")
            print("\(statusCode) \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
            print("  requestHeader: \(request.allHTTPHeaderFields ?? [:])")
            if let httpBody = request.httpBody {
                print("  requestBody: \(String(data: httpBody, encoding: .utf8) ?? "")")
            }
            print("")
        #endif
    }
}

public struct APIClientMock: APIClient {
    private let mockData: [(Any.Type, Decodable)]
    
    public init(mockData: [(Any.Type, Decodable)]) {
        self.mockData = mockData
    }
    
    public func send<R>(request: R) -> AnyPublisher<R.Response, Error> where R : Request {
        Future<R.Response, Error> { promise in
            self.mockData.forEach { (key, value) in
                if R.self == key {
                    promise(.success(value as! R.Response))
                    return
                }
                promise(.failure(HTTPError.unknown))
            }
        }.eraseToAnyPublisher()
    }
}
