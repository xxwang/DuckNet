import Foundation

public enum DNError: Swift.Error {
    /// 请求被取消
    case cancelled
    /// 请求失败
    case failure(Swift.Error)
    /// 未获取到数据
    case noData
    /// 转数据失败
    case mapFailed
}

// MARK: - CustomDebugStringConvertible
extension DNError: CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case .cancelled:
            return "请求取消"
        case let .failure(error):
            return "请求失败\(error.localizedDescription)"
        case .noData:
            return "未获取到数据"
        case .mapFailed:
            return "转换数据失败"
        }
    }

    public var debugDescription: String {
        return self.description
    }
}
