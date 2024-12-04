import Foundation

public struct DNResponse {
    /// api
    public let action: DNAction
    /// 请求状态码
    public let statusCode: Int
    /// 响应数据
    public let data: Data?
    /// 请求体对象
    public let request: URLRequest
    /// 请求响应对象
    public let response: HTTPURLResponse
}

// MARK: - CustomDebugStringConvertible
extension DNResponse: CustomDebugStringConvertible {
    public var description: String {
        let json = (try? self.mapJSONString()) ?? "无数据"
        return "状态码: \(self.statusCode) data: \(json)"
    }

    public var debugDescription: String {
        return self.description
    }
}

// MARK: - 获取方法
public extension DNResponse {
    /// 获取文件路径
    var filePath: String {
        return self.action.filePath
    }
}

// MARK: - 格式转换
public extension DNResponse {
    /// 把数据转换为JSON字符串格式
    func mapJSONString() throws -> String {
        if let data {
            return String(data: data, encoding: .utf8) ?? ""
        }
        throw DNError.mapFailed
    }

    /// 把数据转换为字典格式
    func mapDict() throws -> [String: Any] {
        if let data {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            } catch {
                throw DNError.mapFailed
            }
        }
        throw DNError.mapFailed
    }

    /// 把数据转成模型
    func mapModel<T>(_ model: T.Type) throws -> T? where T: Codable {
        guard let data else { return nil }
        let model = try? JSONDecoder().decode(T.self, from: data)
        return model
    }
}
