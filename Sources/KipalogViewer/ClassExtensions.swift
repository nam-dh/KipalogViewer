//
//  ClassExtensions.swift
//  KipalogViewer
//
//  Created by Nam Doan on 2018/06/18.
//

import KipalogAPI

extension KipalogAPI.PostListType {
    var title: String {
        switch self {
        case .hot:
            return "hot"
        case .latest:
            return "latest"
        case .tag:
            return "tag"
        }
    }

    var tagName: String {
        switch self {
        case .tag(let name):
            return name
        default:
            return ""
        }
    }
}

extension KLServerPost {
    var dict: [String: String] {
        let preview = String(content.prefix(300)).markdownToHTML?.removeHTMLTag() ?? ""
        return [
            "id": id,
            "title": title,
            "preview": preview + " ..."
        ]
    }
}

extension String {
    func removeHTMLTag() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)

    }
}
