import Foundation

public protocol JSONPostRouter: Router {
    func postJSON<T>(_ expectedResultType: T.Type, completion: (json: T?, error: ErrorProtocol?) -> Void)
}

public extension JSONPostRouter {
    public func postJSON<T>(_ expectedResultType: T.Type, completion: (json: T?, error: ErrorProtocol?) -> Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            if let request = request() {
                let task = URLSession.shared().uploadTask(with: request as URLRequest, from: data) { data, response, error in
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode != 201 {
                            let error = NSError(domain: errorDomain, code: response.statusCode, userInfo: nil)
                            completion(json: nil, error: error)
                            return
                        }
                    }

                    if let error = error {
                        completion(json: nil, error: error)
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
        } catch {
            completion(json: nil, error: error)
        }
    }
}
