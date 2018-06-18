//
//  ContentCache.swift
//  KipalogViewer
//
//  Created by Nam Doan on 2018/06/18.
//

import Foundation
import KipalogAPI

final class ContentCache {
    static func titleKey(for id: String) -> String {
        return id + "_title"
    }

    static func contentKey(for id: String) -> String {
        return id + "_content"
    }

    static func cachePosts(_ posts: [KLServerPost]) {
        DispatchQueue.global().async {
            posts.forEach { (post) in
                RedisManager.shared.setValue(post.title, for: titleKey(for: post.id))
                RedisManager.shared.setValue(post.content, for: contentKey(for: post.id))
            }
        }
    }

    static func getCachePost(id: String, completion: @escaping (KLServerPost?) -> Void) {
        RedisManager.shared.getValue(for: titleKey(for: id)) { (title) in
            guard let title = title else {
                return completion(nil)
            }
            RedisManager.shared.getValue(for: contentKey(for: id), completion: { (content) in
                guard let content = content else {
                    return completion(nil)
                }
                let post = KLServerPost(id: id, title: title, content: content, type: .markdown)
                completion(post)
            })
        }
    }
}
