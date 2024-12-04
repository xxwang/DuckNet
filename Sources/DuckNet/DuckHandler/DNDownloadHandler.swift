import Foundation

class DNDownloadHandler: DNHandler, URLSessionDownloadDelegate, @unchecked Sendable {
    // 监控下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.progressBlock?(progress)
    }

    // 下载完成
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response as? HTTPURLResponse else {
            self.didReceiveBlock?(.failure(.noData))
            self.completionBlock?(.failure(.noData))
            return
        }

        let dnResponse = DNResponse(
            action: self.action,
            statusCode: response.statusCode,
            data: nil,
            request: downloadTask.currentRequest!,
            response: response
        )

        guard case .download = self.action.task,
              let fileUrl = self.action.fileUrl
        else {
            self.didReceiveBlock?(.success(dnResponse))
            self.processBlock?(.success(dnResponse))
            return
        }

        do {
            if FileManager.default.fileExists(atPath: self.action.filePath) {
                try? FileManager.default.removeItem(atPath: self.action.filePath)
            }
            try FileManager.default.moveItem(at: location, to: fileUrl)
            self.didReceiveBlock?(.success(dnResponse))
            self.processBlock?(.success(dnResponse))
        } catch {
            self.didReceiveBlock?(.failure(.noData))
            self.processBlock?(.failure(.noData))
        }
    }

    // 下载任务完成或失败
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
