import Foundation

// MARK: - EncodeType
public enum EncodeType {
    /// JSON方式编码
    case JSON
    /// URL方式编码
    case URL
}

// MARK: - DNTask
public enum DNTask {
    /// 普通请求方法
    case request(parameters: [String: Any] = [:], encoding: EncodeType = .JSON)
    /// 上传请求方法
    case upload(formDatas: [DNFormData], parameters: [String: Any] = [:])
    /// 下载请求方法
    case download(parameters: [String: Any] = [:], encoding: EncodeType = .URL, destination: Any)
}
