import Foundation

// MARK: - DNEncoder
public protocol DNEncoder {
    /// 默认创建
    static var `default`: DNEncoder { get }
    /// 编码方法
    func encode(_ action: DNAction, parameters: [String: Any]) -> URLRequest
}

// MARK: - DNJSONEncoder
public class DNJSONEncoder: DNEncoder {
    public static var `default`: any DNEncoder {
        return DNJSONEncoder()
    }

    public func encode(_ action: DNAction, parameters: [String: Any]) -> URLRequest {
        var url = action.baseURL
        if !action.path.isEmpty {
            url = url.appendingPathComponent(action.path)
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = action.method.rawValue

        // 请求头处理
        var headers = action.headers ?? [:]
        if headers.keys.contains("Content-Type"), headers["Content-Type"] == "application/x-www-form-urlencoded" {
            let keyValues = parameters.map { key, value in
                "\(key)=\(value)"
            }
            let httpBodyString = keyValues.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let httpBody = httpBodyString?.data(using: .utf8)
            request.httpBody = httpBody
            request.allHTTPHeaderFields = headers
            return request
        } else if case .download = action.task {
            if !headers.keys.contains("Content-Type") {
                headers["Content-Type"] = "application/octet-stream"
            }

            if !headers.keys.contains("Accept") {
                headers["Accept"] = "application/octet-stream"
            }
        } else if !headers.keys.contains("Content-Type") {
            headers["Content-Type"] = "application/json"
        }
        request.allHTTPHeaderFields = headers

        // 序列化
        let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = httpBody

        return request
    }
}

// MARK: - DNURLEncoder
public class DNURLEncoder: DNEncoder {
    public static var `default`: any DNEncoder {
        return DNURLEncoder()
    }

    public func encode(_ action: DNAction, parameters: [String: Any]) -> URLRequest {
        var url = action.baseURL
        if !action.path.isEmpty {
            url = url.appendingPathComponent(action.path)
        }

        // 创建请求
        var request = URLRequest(url: url)
        request.httpMethod = action.method.rawValue

        // 请求头处理
        var headers = action.headers ?? [:]
        if headers.keys.contains("Content-Type"), headers["Content-Type"] == "application/x-www-form-urlencoded" {
            let keyValues = parameters.map { key, value in
                "\(key)=\(value)"
            }
            let httpBodyString = keyValues.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let httpBody = httpBodyString?.data(using: .utf8)
            request.httpBody = httpBody
            request.allHTTPHeaderFields = headers
            return request
        } else if case .download = action.task {
            if !headers.keys.contains("Content-Type") {
                headers["Content-Type"] = "application/octet-stream"
            }

            if !headers.keys.contains("Accept") {
                headers["Accept"] = "application/octet-stream"
            }
        } else if !headers.keys.contains("Content-Type") {
            headers["Content-Type"] = "application/json"
        }
        request.allHTTPHeaderFields = headers

        guard parameters.count > 0 else { return request }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        urlComponents.queryItems = queryItems
        request.url = urlComponents.url ?? url

        return request
    }
}

// MARK: - DNUploadENcoder
public class DNUploadEncoder: DNEncoder {
    public static var `default`: any DNEncoder {
        return DNUploadEncoder()
    }

    public func encode(_ action: DNAction, parameters: [String: Any]) -> URLRequest {
        var url = action.baseURL
        if !action.path.isEmpty {
            url = url.appendingPathComponent(action.path)
        }

        let kUploadBoundary = "com.duck.net"

        var request = URLRequest(url: url)
        request.httpMethod = action.method.rawValue
        request.allHTTPHeaderFields = action.headers ?? [:]
        request.setValue("multipart/form-data; boundary=\(kUploadBoundary)", forHTTPHeaderField: "Content-Type")

        guard case let .upload(formDatas, _, _) = action.task else {
            return request
        }

        // 请求体数据
        var body = Data()

        // 开始边界
        let boundaryPrefix = "--\(kUploadBoundary)\r\n"
        // 结束边界
        let boundarySuffix = "\r\n--\(kUploadBoundary)--\r\n"

        // 添加表单参数
        for (key, value) in parameters {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // 添加文件数据
        for formData in formDatas {
            // 可以根据文件类型动态设置
            let mimeType = formData.mimeType
            let contentDisposition = "Content-Disposition: form-data; name=\"files[]\"; filename=\"\(formData.fileName)\"\r\n"
            let contentType = "Content-Type: \(mimeType)\r\n\r\n"
            let fileData = formData.data

            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append(contentDisposition.data(using: .utf8)!)
            body.append(contentType.data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // 结束边界
        body.append(boundarySuffix.data(using: .utf8)!)

        request.httpBody = body

        return request
    }
}
