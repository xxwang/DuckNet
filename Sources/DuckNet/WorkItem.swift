import Foundation

public class WorkItem {
    /// 请求API
    var action: DNAction
    /// 请求回调处理对象
    var handler: DNHandler
    /// 请求结果回调队列
    var callbackQueue: OperationQueue?
    /// 超时时间
    var timeout: TimeInterval
    /// 是否取消
    var isCancelled: Bool = false

    /// 请求会话配置
    var sessionConfiguration: URLSessionConfiguration {
        // 默认配置
        let configuration = URLSessionConfiguration.default
        // 超时时间
        configuration.timeoutIntervalForRequest = self.timeout
        configuration.timeoutIntervalForResource = self.timeout * 60
        // 缓存策略
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        // 是否允许蜂窝网络访问
        configuration.allowsCellularAccess = true
        // 每个主机的最大连接数
        configuration.httpMaximumConnectionsPerHost = 5
        // 是否等待网络连接
        configuration.waitsForConnectivity = true
        // 网络服务类型
        configuration.networkServiceType = .default
        // 是否等待网络连接
        configuration.waitsForConnectivity = true
        return configuration
    }

    /// 请求对象
    var urlRequest: URLRequest!
    /// 请求会话
    var session: URLSession!
    /// 请求任务
    var task: URLSessionTask!

    init(_ action: DNAction,
         handler: DNHandler,
         callbackQueue: OperationQueue?,
         timeout: TimeInterval)
    {
        self.action = action
        self.handler = handler
        self.callbackQueue = callbackQueue
        self.timeout = timeout

        // 创建请求会话
        self.session = URLSession(configuration: self.sessionConfiguration, delegate: handler, delegateQueue: callbackQueue)
    }
}

public extension WorkItem {
    /// 准备请求
    func prepare() {
        if let block = self.handler.prepareBlock {
            self.urlRequest = block(self.urlRequest)
        }

        switch self.action.task {
        case .request:
            self.task = self.session.dataTask(with: self.urlRequest)
        case .upload:
            self.task = self.session.uploadTask(with: self.urlRequest, from: Data())
        case .download:
            self.task = self.session.downloadTask(with: self.urlRequest)
        }
    }

    /// 开始请求
    func start() {
        if self.isCancelled {
            self.handler.cancelledBlock?(.failure(.cancelled))
            self.handler.completionBlock?(.failure(.cancelled))
        } else {
            self.task.resume()
        }
    }

    /// 取消请求
    func cancel() {
        self.isCancelled = true
        self.task.cancel()
    }
}
