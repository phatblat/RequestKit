import Foundation

public extension String {
    func stringByAppendingURLPath(_ path: String) -> String {
        return path.hasPrefix("/") ? self + path : self + "/" + path
    }

    func urlEncodedString() -> String? {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let characterSet = CharacterSet.urlQueryAllowed.mutableCopy() as! NSMutableCharacterSet
        characterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}
