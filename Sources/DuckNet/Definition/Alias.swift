import Foundation

/// 进度回调
public typealias DNProgressBlock = (Float) -> Void
/// 完成回调
public typealias DNCompletionBlock = (Result<DNResponse, DNError>) -> Void
/// 取消请求的回调
public typealias DNCancelledBlock = (Result<DNResponse, DNError>) -> Void

/// 请求发送前拦截器
public typealias DNPrepareBlock = (URLRequest) -> URLRequest
/// 即将发送拦截器
public typealias DNWillSendBlock = (WorkItem) -> Void
/// 接收到响应拦截器
public typealias DNDidReceiveBlock = (Result<DNResponse, DNError>) -> Void
/// 处理响应数据拦截器
public typealias DNProcessBlock = (Result<DNResponse, DNError>) -> Void
