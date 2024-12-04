import Foundation

class URLRequestBuilder {
    /// 请求API
    var action: DNAction

    init(_ action: DNAction) {
        self.action = action
    }
}

extension URLRequestBuilder {
    /// 构造URLRequest
    func urlRequest() -> URLRequest {
        switch self.action.task {
        case let .request(parameters, encoder): // 普通请求
            return encoder.encode(self.action, parameters: parameters)
        case let .upload(_, parameters, encoder): // 上传请求
            return encoder.encode(self.action, parameters: parameters)
        case let .download(parameters, encoder, _): // 下载请求
            return encoder.encode(self.action, parameters: parameters)
        }
    }
}
