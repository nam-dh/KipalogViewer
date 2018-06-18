//
//  Application.swift
//  KipalogViewer
//
//  Created by Nam Doan on 2018/06/16.
//

import Foundation
import Kitura
import LoggerAPI
import KituraStencil
import KipalogAPI
import PerfectMarkdown

final class App {
    let router = Router()
    
    func run() {
        setupRoutes()

        // Resolve the port that we want the server to listen on.
        let port: Int = ProcessInfo.processInfo.environment["PORT"]
            .flatMap({ Int($0) }) ?? 8080
        Kitura.addHTTPServer(onPort: port, with: router)
        Kitura.run()
    }

    private func setupRoutes() {
        router.setDefault(templateEngine: StencilTemplateEngine())
        router.get("/") { request, response, next in
            self.getPostListAndResponse(for: .hot, response: response)

        }
        router.get("/hot") { request, response, next in
            self.getPostListAndResponse(for: .hot, response: response)
        }
        router.get("/latest") { request, response, next in
            self.getPostListAndResponse(for: .latest, response: response)
        }
        router.get("/tags/:tag") { request, response, next in
            let tagName = request.parameters["tag"] ?? ""
            self.getPostListAndResponse(for: .tag(tagName), response: response)
        }
        router.get("/post/:id") { request, response, next in
            let id = request.parameters["id"] ?? ""
            self.getCachePostAndResponse(id: id, response: response)
        }
        router.all(middleware: StaticFileServer())
    }

    private func getPostListAndResponse(for type: KipalogAPI.PostListType, response: RouterResponse) {
        KipalogAPI.shared.getPostList(type: type) { (result) in
            if let posts = result.value {
                // Cache to Redis
                ContentCache.cachePosts(posts)
                self.responseHome(response, posts: posts, type: type)
            } else {
                response.send("Error")
            }
        }
    }

    private func responseHome(_ response: RouterResponse, posts: [KLServerPost], type: KipalogAPI.PostListType = .hot) {
        let dictList = posts.compactMap({ $0.dict })
        do {
            let context: [String: Any] = [
                "type": type.title,
                "tag_name": type.tagName,
                "list": dictList,
                ]
            try response.render("home", context: context)
        } catch {
            response.send("Error")
        }
    }

    private func getCachePostAndResponse(id: String, response: RouterResponse) {
        guard !id.isEmpty else {
            response.send("Empty ID")
            return
        }
        ContentCache.getCachePost(id: id) { (post) in
            guard let post = post else {
                response.send("Empty cache")
                return
            }
            self.responsePost(response, post: post)
        }
    }

    private func responsePost(_ response: RouterResponse, post: KLPost) {
        let htmlContent: String = {
            switch post.type {
            case .html:
                return post.content
            case .markdown:
                return post.content.markdownToHTML ?? ""
            }
        }()
        do {
            let context: [String: Any] = [
                "title": post.title,
                "content": htmlContent
            ]
            try response.render("post", context: context)
        } catch {
            response.send("Error when rendering response")
        }
    }

    private func getPreviewAndResponsePost(_ response: RouterResponse, post: KLPost) {
        KipalogAPI.shared.accessToken = ""
        let markdownPost = KLLocalPost(title: post.title, content: post.content, tags: [], type: .markdown)
        KipalogAPI.shared.preview(markdownPost) { (result) in
            if let htmlPost = result.value {
                self.responsePost(response, post: htmlPost)
            } else {
                response.send("Error when getting Preview")
            }
        }
    }
}
