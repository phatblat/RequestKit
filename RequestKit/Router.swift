import Foundation

let errorDomain = "com.octokit.swift"

public enum Response<T> {
    case success(T)
    case failure(ErrorProtocol)
}

public enum HTTPMethod: String {
    case GET = "GET", POST = "POST"
}

public enum HTTPEncoding: Int {
    case url, form, json
}

public protocol Configuration {
    var apiEndpoint: String { get }
    var accessToken: String? { get }
    var accessTokenFieldName: String { get }
}

public extension Configuration {
    var accessTokenFieldName: String {
        return "access_token"
    }
}

public protocol Router {
    var method: HTTPMethod { get }
    var path: String { get }
    var encoding: HTTPEncoding { get }
    var params: [String: String] { get }
    var configuration: Configuration { get }

    func urlQuery(_ parameters: [String: String]) -> String
    func request(_ urlString: String, parameters: [String: String]) -> URLRequest?
    func loadJSON<T>(_ expectedResultType: T.Type, completion: (json: T?, error: ErrorProtocol?) -> Void)
    func request() -> URLRequest?
}

public extension Router {
    public func request() -> URLRequest? {
        let URLString = configuration.apiEndpoint.stringByAppendingURLPath(path)
        var parameters = encoding == .json ? [:] : params
        if let accessToken = configuration.accessToken {
            parameters[configuration.accessTokenFieldName] = accessToken
        }
        return request(URLString, parameters: parameters)
    }

    public func urlQuery(_ parameters: [String: String]) -> String {
        var components: [(String, String)] = []
        for key in parameters.keys.sorted(isOrderedBefore: <) {
            if let value = parameters[key] {
                let encodedValue = value.urlEncodedString()
                components.append(key, encodedValue!)
            }
        }

        return components.map{"\($0)=\($1)"}.joined(separator: "&")
    }

    public func request(_ urlString: String, parameters: [String: String]) -> URLRequest? {
        var URLString = urlString
        switch encoding {
        case .url, .json:
            if parameters.keys.count > 0 {
                URLString = [URLString, urlQuery(parameters) ?? ""].joined(separator: "?")
            }
            if let URL = URL(string: URLString) {
                let mutableURLRequest = NSMutableURLRequest(url: URL)
                mutableURLRequest.httpMethod = method.rawValue
                return mutableURLRequest as URLRequest
            }
        case .form:
            let queryData = urlQuery(parameters).data(using: String.Encoding.utf8)
            if let URL = URL(string: URLString) {
                let mutableURLRequest = NSMutableURLRequest(url: URL)
                mutableURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
                mutableURLRequest.httpBody = queryData
                mutableURLRequest.httpMethod = method.rawValue
                return mutableURLRequest as URLRequest
            }
        }

        return nil
    }

    public func loadJSON<T>(_ expectedResultType: T.Type, completion: (json: T?, error: ErrorProtocol?) -> Void) {
        if let request = request() {
            let task = URLSession.shared().dataTask(with: request) { data, response, err in
                if let response = response as? HTTPURLResponse {
                    if response.wasSuccessful == false {
                        let error = NSError(domain: errorDomain, code: response.statusCode, userInfo: nil)
                        completion(json: nil, error: error)
                        return
                    }
                }

                if let err = err {
                    completion(json: nil, error: err)
                } else {
                    if let data = data {
                        do {
                            let JSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? T
                            completion(json: JSON, error: nil)
                        } catch {
                            completion(json: nil, error: error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}

public extension HTTPURLResponse {
    public var wasSuccessful: Bool {
        let successRange = 200..<300
        return successRange.contains(statusCode)
    }
}
