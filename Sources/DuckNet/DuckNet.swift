import Foundation

public class DuckNet<Action: DNAction> {
    /// 超时时间
    var timeout: TimeInterval = 60
    /// 请求结果回调队列
    var callbackQueue: OperationQueue?
    /// 拦截器
    var interceptors: [any DNInterceptor] = []
    /// 取消请求的回调
    var cancelledBlock: DNCancelledBlock?

    public init() {}
}

// MARK: - 属性设置
public extension DuckNet {
    /// 添加单个拦截器
    @discardableResult
    func add(interceptor: any DNInterceptor) -> Self {
        self.interceptors.append(interceptor)
        return self
    }

    /// 添加多个拦截器
    @discardableResult
    func add(interceptors: [any DNInterceptor]) -> Self {
        self.interceptors.append(contentsOf: interceptors)
        return self
    }

    /// 设置超时时间
    @discardableResult
    func timeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }

    /// 设置默认回调队列
    @discardableResult
    func callbackQueue(_ callbackQueue: OperationQueue?) -> Self {
        self.callbackQueue = callbackQueue
        return self
    }

    /// 取消回调
    @discardableResult
    func canceledCallback(_ cancelled: DNCancelledBlock?) -> Self {
        self.cancelledBlock = cancelled
        return self
    }
}

// MARK: - 请求
public extension DuckNet {
    /// 请求方法
    /// - Parameters:
    ///   - action: 请求API
    ///   - callbackQueue: 回调队列
    ///   - progress: 请求进度回调
    ///   - completion: 请求完成回调
    /// - Returns: 请求管理对象
    @discardableResult
    func request(_ action: Action,
                 callbackQueue: OperationQueue? = nil,
                 progress: DNProgressBlock? = nil,
                 completion: @escaping DNCompletionBlock) -> WorkItem
    {
        // 回调处理对象
        let handler = handler(with: action,
                              progress: progress,
                              completion: completion)

        // 请求管理对象
        let workItem = WorkItem(action,
                                handler: handler,
                                callbackQueue: callbackQueue ?? self.callbackQueue,
                                timeout: self.timeout)

        // 执行请求
        return self.execute(workItem)
    }

    /// 执行请求
    /// - Parameter workItem: 请求管理对象
    private func execute(_ workItem: WorkItem) -> WorkItem {
        // 准备请求
        workItem.prepare()

        // 开始请求
        workItem.start()

        return workItem
    }

    /// 创建回调处理对象
    /// - Parameters:
    ///   - action: 请求API
    /// - Returns: 处理对象
    private func handler(with action: Action,
                         progress: DNProgressBlock? = nil,
                         completion: @escaping DNCompletionBlock) -> DNHandler
    {
        let handler: DNHandler = switch action.task {
        case .request:
            DNRequestHandler(action)
        case .upload:
            DNUploadHandler(action)
        case .download:
            DNDownloadHandler(action)
        }

        // 请求发送前回调
        let prepareBlock = { [weak self] (request: URLRequest) -> URLRequest in
            guard let self else { return request }
            let request = self.interceptors.reduce(request) {
                $1.prepare(action, request: request)
            }
            return request
        }

        // 即将发送回调
        let willSendBlock = { [weak self] (workItem: WorkItem) in
            guard let self else { return }
            for interceptor in self.interceptors {
                interceptor.willSend(action, workItem: workItem)
            }
        }

        // 接收到响应回调
        let didReceiveBlock = { [weak self] (result: Result<DNResponse, DNError>) in
            guard let self else { return }
            for interceptor in self.interceptors {
                interceptor.didReceive(action, result: result)
            }
        }

        // 响应数据处理回调
        let processBlock: DNProcessBlock = { [weak self] (result: Result<DNResponse, DNError>) in
            guard let self else { return }
            let processedResult = self.interceptors.reduce(result) {
                $1.process(action, result: $0)
            }
            handler.completionBlock?(processedResult)
        }

        handler.prepareBlock = prepareBlock
        handler.willSendBlock = willSendBlock
        handler.didReceiveBlock = didReceiveBlock
        handler.processBlock = processBlock

        handler.progressBlock = progress
        handler.completionBlock = completion
        handler.cancelledBlock = self.cancelledBlock

        return handler
    }
}
