import Foundation

public extension String {
    func stringByAppendingURLPath(_ path: String) -> String {
        return path.hasPrefix("/") ? self + path : self + "/" + path
    }

    func urlEncodedString() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        // Using CharacterSet.urlQueryAllowed crashes - http://openradar.appspot.com/26880260
        var characterSet = NSCharacterSet.urlQueryAllowed()
        characterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}
