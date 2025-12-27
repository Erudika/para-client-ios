import Foundation

/// Lightweight JSON helper that replaces the SwiftyJSON dependency.
public struct JSON: Equatable {
	private let value: Any

	public static let null = JSON(NSNull())

	public init(_ value: Any?) {
		self.value = JSON.normalize(value)
	}

	public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
		let object = try JSONSerialization.jsonObject(with: data, options: options)
		self.init(object)
	}

	/// Returns the underlying dictionary, if any.
	public var dictionaryObject: [String: Any]? {
		if let dict = value as? [String: Any] {
			return dict
		}
		if let dict = value as? NSDictionary {
			return dict as? [String: Any]
		}
		return nil
	}

	/// Returns the dictionary as JSON-wrapped values.
	public var dictionaryValue: [String: JSON] {
		guard let dict = dictionaryObject else { return [:] }
		var result: [String: JSON] = [:]
		for (key, val) in dict {
			result[key] = JSON(val)
		}
		return result
	}

	/// Returns the array value, if any.
	public var arrayValue: [JSON] {
		if let array = value as? [Any] {
			return array.map { JSON($0) }
		}
		if let nsArray = value as? NSArray, let bridged = nsArray as? [Any] {
			return bridged.map { JSON($0) }
		}
		return []
	}

	public var stringValue: String {
		if let string = value as? String {
			return string
		}
		if let number = value as? NSNumber {
			return number.stringValue
		}
		return ""
	}

	public var uIntValue: UInt {
		if let number = value as? NSNumber {
			return number.uintValue
		}
		if let string = value as? String, let parsed = UInt(string) {
			return parsed
		}
		return 0
	}

	public var uInt64Value: UInt64 {
		if let number = value as? NSNumber {
			return number.uint64Value
		}
		if let string = value as? String, let parsed = UInt64(string) {
			return parsed
		}
		return 0
	}

	public func rawString(options: JSONSerialization.WritingOptions = []) -> String? {
		switch value {
			case is NSNull:
				return "null"
			case let string as String:
				return string
			case let number as NSNumber:
				return number.stringValue
			default:
				guard let data = rawData(options: options) else { return nil }
				return String(data: data, encoding: .utf8)
		}
	}

	public func rawData(options: JSONSerialization.WritingOptions = []) -> Data? {
		let normalized = JSON.toJSONCompatible(value)
		if JSONSerialization.isValidJSONObject(normalized) {
			return try? JSONSerialization.data(withJSONObject: normalized, options: options)
		}
		if let string = normalized as? String {
			return string.data(using: .utf8)
		}
		if let number = normalized as? NSNumber {
			return number.stringValue.data(using: .utf8)
		}
		if normalized is NSNull {
			return "null".data(using: .utf8)
		}
		return nil
	}

	public subscript(key: String) -> JSON {
		guard let dict = dictionaryObject, let item = dict[key] else {
			return JSON.null
		}
		return JSON(item)
	}

	public subscript(index: Int) -> JSON {
		let array = arrayValue
		if index >= 0 && index < array.count {
			return array[index]
		}
		return JSON.null
	}

	public var isNull: Bool {
		return value is NSNull
	}

	public static func == (lhs: JSON, rhs: JSON) -> Bool {
		switch (lhs.value, rhs.value) {
			case (is NSNull, is NSNull):
				return true
			default:
				let left = JSON.toNSObject(lhs.value)
				let right = JSON.toNSObject(rhs.value)
				return left?.isEqual(right) ?? false
		}
	}

	// MARK: - Helpers

	private static func normalize(_ value: Any?) -> Any {
		guard let value = value else { return NSNull() }
		if let json = value as? JSON { return json.value }
		if let dict = value as? [String: Any] {
			var normalized: [String: Any] = [:]
			for (key, val) in dict {
				normalized[key] = normalize(val)
			}
			return normalized
		}
		if let dict = value as? NSDictionary, let bridged = dict as? [String: Any] {
			return normalize(bridged)
		}
		if let array = value as? [Any] {
			return array.map { normalize($0) }
		}
		if let nsArray = value as? NSArray, let bridged = nsArray as? [Any] {
			return bridged.map { normalize($0) }
		}
		return value
	}

	private static func toJSONCompatible(_ value: Any) -> Any {
		if let dict = value as? [String: Any] {
			var normalized: [String: Any] = [:]
			for (key, val) in dict {
				normalized[key] = toJSONCompatible(val)
			}
			return normalized
		}
		if let dict = value as? NSDictionary, let bridged = dict as? [String: Any] {
			return toJSONCompatible(bridged)
		}
		if let array = value as? [Any] {
			return array.map { toJSONCompatible($0) }
		}
		if let nsArray = value as? NSArray, let bridged = nsArray as? [Any] {
			return bridged.map { toJSONCompatible($0) }
		}
		return value
	}

	private static func toNSObject(_ value: Any) -> NSObject? {
		switch value {
			case let dict as [String: Any]:
				return toJSONCompatible(dict) as? NSDictionary
			case let array as [Any]:
				return toJSONCompatible(array) as? NSArray
			case let nsObject as NSObject:
				return nsObject
			default:
				return nil
		}
	}
}

extension JSON: @unchecked Sendable {}
