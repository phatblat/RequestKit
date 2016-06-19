import XCTest
import RequestKit

class RouterTests: XCTestCase {
    lazy var router: TestRouter = {
        let config = TestConfiguration("1234", url: "https://example.com/api/v1")
        let router = TestRouter.testRoute(config)
        return router
    }()

    func testRequest() {
        let subject = router.request()
        XCTAssertEqual(subject?.url?.absoluteString, "https://example.com/api/v1/some_route?access_token=1234&key1=value1&key2=value2")
        XCTAssertEqual(subject?.httpMethod, "GET")
    }

    func testWasSuccessful() {
        let url = URL(string: "https://example.com/api/v1")!
        let response200 = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertTrue(response200.wasSuccessful)
        let response201 = HTTPURLResponse(url: url, statusCode: 201, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertTrue(response201.wasSuccessful)
        let response400 = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertFalse(response400.wasSuccessful)
        let response300 = HTTPURLResponse(url: url, statusCode: 300, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertFalse(response300.wasSuccessful)
        let response301 = HTTPURLResponse(url: url, statusCode: 301, httpVersion: "HTTP/1.1", headerFields: [:])!
        XCTAssertFalse(response301.wasSuccessful)
    }
}

enum TestRouter: Router {
    case testRoute(Configuration)

    var configuration: Configuration {
        switch self {
        case .testRoute(let config): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .testRoute:
            return .GET
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .testRoute:
            return .url
        }
    }

    var path: String {
        switch self {
        case .testRoute:
            return "some_route"
        }
    }

    var params: [String: String] {
        switch self {
        case .testRoute(_):
            return ["key1": "value1", "key2": "value2"]
        }
    }

    var URLRequest: Foundation.URLRequest? {
        switch self {
        case .testRoute(_):
            return request()
        }
    }
}

