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

public class App {
    let router = Router()
    
    public func run() {
        setupRoutes()

        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }

    private func setupRoutes() {
        router.setDefault(templateEngine: StencilTemplateEngine())
        router.get("/") { request, response, next in
            KipalogAPI.shared.getPostList(type: .hot) { (result) in
                self.response(response, with: result.value ?? [], type: .hot)
            }
        }
        router.get("/hot") { request, response, next in
            KipalogAPI.shared.getPostList(type: .hot) { (result) in
                self.response(response, with: result.value ?? [], type: .hot)
            }
        }
        router.get("/latest") { request, response, next in
            KipalogAPI.shared.getPostList(type: .latest) { (result) in
                self.response(response, with: result.value ?? [], type: .latest)
            }
        }
        router.get("/tags/:tag") { request, response, next in
            let tagName = request.parameters["tag"] ?? ""
            KipalogAPI.shared.getPostList(type: .tag(tagName)) { (result) in
                self.response(response, with: result.value ?? [], type: .tag(tagName))
            }
        }
        router.all(middleware: StaticFileServer())
    }

    private func response(_ response: RouterResponse, with posts: [KLServerPost], type: KipalogAPI.PostListType = .hot) {
        let list = posts.compactMap({ $0.dict })
        do {
            let context: [String: Any] = [
                "type": type.title,
                "tag_name": type.tagName,
                "list": list,
                ]
            try response.render("home", context: context)
        } catch {
            response.send("Error")
        }
    }
}

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
        let stripTagString = content.markdownToHTML?.removeHTMLTag() ?? ""
        return [
            "id": id,
            "title": title,
            "summary": String(stripTagString.prefix(300)) + " ..."
        ]
    }
}

extension String {
    func removeHTMLTag() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)

    }
}
