import Foundation

public struct DNFormDataItem: Hashable {
    /// 要上传的数据
    public let data: Data
    /// 文件名
    public let fileName: String
    /// 文件类型
    public let mimeType: String

    public init(data: Data, fileName: String, mimeType: String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
