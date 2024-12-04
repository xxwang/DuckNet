import Foundation

class DNHandler: NSObject, @unchecked Sendable {
    var action: DNAction
    /// 请求进度回调
    var progressBlock: DNProgressBlock?
    /// 请求完成回调
    var completionBlock: DNCompletionBlock?
    /// 取消请求的回调
    var cancelledBlock: DNCancelledBlock?

    /// 准备请求拦截器回调
    var prepareBlock: DNPrepareBlock?
    /// 即将发送请求拦截器回调
    var willSendBlock: DNWillSendBlock?
    /// 接收到响应拦截器回调
    var didReceiveBlock: DNDidReceiveBlock?
    /// 处理响应拦截器回调
    var processBlock: DNProcessBlock?

    init(_ action: DNAction) {
        self.action = action
    }
}

extension DNHandler: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {}
