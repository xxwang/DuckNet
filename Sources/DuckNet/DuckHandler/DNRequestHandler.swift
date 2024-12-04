import Foundation

class DNRequestHandler: DNHandler, @unchecked Sendable {
    // 监控上传进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.progressBlock?(progress)
    }

    // 处理响应头信息
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }

    // 处理返回的数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let response = dataTask.response as? HTTPURLResponse else {
            self.didReceiveBlock?(.failure(.noData))
            self.completionBlock?(.failure(.noData))
            return
        }

        let dnResponse = DNResponse(
            action: self.action,
            statusCode: response.statusCode,
            data: data,
            request: dataTask.currentRequest!,
            response: response
        )
        self.didReceiveBlock?(.success(dnResponse))
        self.processBlock?(.success(dnResponse))
    }

    // 处理请求完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? NSError, error.code == NSURLErrorCancelled {
            self.cancelledBlock?(.failure(.cancelled))
            self.completionBlock?(.failure(.cancelled))
        } else if let error {
            self.didReceiveBlock?(.failure(.failure(error)))
            self.completionBlock?(.failure(.failure(error)))
        }
    }
}
