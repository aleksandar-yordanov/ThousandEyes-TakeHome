//
//  ThousandEyes_TakeHomeTests.swift
//  ThousandEyes-TakeHomeTests
//
//  Created by Aleksandar Yordanov on 18/04/2025.
//

import XCTest
import Foundation
@testable import ThousandEyes_TakeHome

final class MockURLProtocol: URLProtocol {
    // Very good mock URL protocol to test networking.
    // https://www.swiftwithvincent.com/blog/how-to-mock-any-network-call-with-urlprotocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
  
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("No request handler provided.")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            XCTFail("Error handling the request: \(error)")
        }
    }
  
    override func stopLoading() {}
}

final class TakeHomeModelTests: XCTestCase {
    
    func testSiteModelDecodingFromJSON() throws {
        let data = """
        [
          {
            "name": "Example",
            "url": "https://example.com",
            "icon": "https://example.com/icon.png",
            "description": "Description"
          }
        ]
        """.data(using: .utf8)!
        
        let sites = try JSONDecoder().decode([Site].self, from: data)
        
        XCTAssertEqual(sites.count, 1, "One site decoded")
        XCTAssertEqual(sites[0].name, "Example")
        XCTAssertEqual(sites[0].url.absoluteString, "https://example.com")
        XCTAssertEqual(sites[0].icon.absoluteString, "https://example.com/icon.png")
        XCTAssertEqual(sites[0].description, "Description")
    }
}

final class TakeHomeNetworkingTests: XCTestCase {
    private var service: NetworkService!
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self) // Register our mock URL protocol, such that URL protocol selectively uses MockURLProtocol
        service = NetworkService()
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self) // Unregister on teardown.
        service = nil
        super.tearDown()
    }
    
    func testSuccessfulRequest() async throws {
        let data = """
        [
          {
            "name": "Example",
            "url": "https://example.com",
            "icon": "https://example.com/icon.png",
            "description": "Description"
          }
        ]
        """.data(using: .utf8)!
        
        let url = try XCTUnwrap(URL(string: AppConfig.apiBaseURL))
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)! // Create mock HTTP request.
        
        MockURLProtocol.requestHandler = {_ in (response, data)}
        
        let sites = try await service.fetchSites()
        
        // Verify that fetched mock data matches expectations.
        XCTAssertEqual(sites.count, 1, "One site decoded")
        XCTAssertEqual(sites[0].name, "Example")
        XCTAssertEqual(sites[0].url.absoluteString, "https://example.com")
        XCTAssertEqual(sites[0].icon.absoluteString, "https://example.com/icon.png")
        XCTAssertEqual(sites[0].description, "Description")
    }
    
    func testRequestFailed() async {
        let url = try! XCTUnwrap(URL(string: AppConfig.apiBaseURL))
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.requestHandler = {_ in (response, Data())}
        // Verify that we get .requestFailed.
        do {
             _ = try await service.fetchSites()
             XCTFail("Expected requestFailed error, but succeeded")
         } catch let error as NetworkError {
             XCTAssertEqual(error, .requestFailed)
         } catch {
             XCTFail("Wrong error type: \(error)")
         }
    }
    
    func testDecodingFailed() async {
        let badData = "{invalid json string}".data(using: .utf8)!
        let url = try! XCTUnwrap(URL(string: AppConfig.apiBaseURL))
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.requestHandler = {_ in (response, badData)}
        // Verify that we get .decodingFailed
        do {
            _ = try await service.fetchSites()
            XCTFail("Expected decodingFailed error, but succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
