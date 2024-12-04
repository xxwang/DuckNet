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
    case request(parameters: [String: Any] = [:], encoder: DNEncoder = DNJSONEncoder.default)
    /// 上传请求方法
    case upload(formDatas: [DNFormDataItem], parameters: [String: Any] = [:], encoder: DNEncoder = DNUploadEncoder.default)
    /// 下载请求方法
    case download(parameters: [String: Any] = [:], encoder: DNEncoder = DNURLEncoder.default, destination: Any)
}
