import Foundation

public protocol DNAction {
    /// 基础URL
    var baseURL: URL { get }

    /// 请求路径
    var path: String { get }

    /// 请求头
    var headers: [String: String]? { get }

    /// 请求方法
    var method: DNMethod { get }

    /// 要执行的任务
    var task: DNTask { get }
}

extension DNAction {
    /// 获取下载文件路径
    var filePath: String {
        if case let .download(_, _, destination) = self.task {
            if let path = destination as? String {
                return path
            } else if let url = destination as? URL {
                return url.absoluteString
            }
        }
        return ""
    }

    /// 获取下载文件URL
    var fileUrl: URL? {
        let url = URL(fileURLWithPath: self.filePath)
        return url
    }
}
