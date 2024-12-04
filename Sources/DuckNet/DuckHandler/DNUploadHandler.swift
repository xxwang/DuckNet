import Foundation

class DNUploadHandler: DNHandler, @unchecked Sendable {
    // 监控上传进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.progressBlock?(progress)
    }

    // 服务器响应
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }

    // 服务器返回的数据
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

    // 上传任务完成或失败
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
