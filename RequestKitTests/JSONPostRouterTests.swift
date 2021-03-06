import RequestKit
import XCTest

class JSONPostRouterTests: XCTestCase {
    func testJSONPostJSONError() {
        let jsonDict = ["message": "Bad credentials", "documentation_url": "https://developer.github.com/v3"]
        let jsonString = String(data: try! NSJSONSerialization.dataWithJSONObject(jsonDict, options: NSJSONWritingOptions()), encoding: NSUTF8StringEncoding)
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "POST", response: jsonString, statusCode: 401)
        TestInterface().postJSON(session) { response in
            switch response {
            case .Success:
                XCTAssert(false, "should not retrieve a succesful response")
            case .Failure(let error as NSError):
                XCTAssertEqual(error.code, 401)
                XCTAssertEqual(error.domain, "com.nerdishbynature.RequestKitTests")
                XCTAssertEqual((error.userInfo[RequestKitErrorResponseKey] as? [String: String]) ?? [:], jsonDict)
            case .Failure:
                XCTAssertTrue(false)
            }
        }
        XCTAssertTrue(session.wasCalled)
    }

    func testJSONPostStringError() {
        let errorString = "Just nope"
        let session = RequestKitURLTestSession(expectedURL: "https://example.com/some_route", expectedHTTPMethod: "POST", response: errorString, statusCode: 401)
        TestInterface().postJSON(session) { response in
            switch response {
            case .Success:
                XCTAssert(false, "should not retrieve a succesful response")
            case .Failure(let error as NSError):
                XCTAssertEqual(error.code, 401)
                XCTAssertEqual(error.domain, "com.nerdishbynature.RequestKitTests")
                XCTAssertEqual((error.userInfo[RequestKitErrorResponseKey] as? String) ?? "", errorString)
            case .Failure:
                XCTAssertTrue(false)
            }
        }
        XCTAssertTrue(session.wasCalled)
    }
}
