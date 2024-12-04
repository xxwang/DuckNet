import Foundation

// MARK: - 拦截器协议
public protocol DNInterceptor: Sendable {
    /// 请求发送前
    func prepare<Action: DNAction>(_ action: Action, request: URLRequest) -> URLRequest
    /// 即将发送
    func willSend<Action: DNAction>(_ action: Action, workItem: WorkItem)
    /// 接收到响应
    func didReceive<Action: DNAction>(_ action: Action, result: Result<DNResponse, DNError>)
    /// 响应数据处理
    func process<Action: DNAction>(_ action: Action, result: Result<DNResponse, DNError>) -> Result<DNResponse, DNError>
}

// MARK: - 拦截器默认实现
public extension DNInterceptor {
    /// 请求发送前
    func prepare(_ action: some DNAction, request: URLRequest) -> URLRequest { request }
    /// 请求准备发送
    func willSend(_ action: some DNAction, workItem: WorkItem) {}
    /// 接收到响应
    func didReceive(_ action: some DNAction, result: Result<DNResponse, DNError>) {}
    /// 响应数据处理
    func process(_ action: some DNAction, result: Result<DNResponse, DNError>) -> Result<DNResponse, DNError> { result }
}
