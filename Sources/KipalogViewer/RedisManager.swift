//
//  RedisManager.swift
//  KipalogViewer
//
//  Created by Nam Doan on 2018/06/18.
//

import Foundation
import SwiftRedis

final class RedisManager {
    static let shared = RedisManager()

    private let redis: Redis
    private let host: String
    private let password: String
    private let port: Int32

    private init() {
        self.redis = Redis()
        let url = URL(string: ProcessInfo.processInfo.environment["REDIS_URL"] ?? "")
        self.host = url?.host ?? "localhost"
        self.port = Int32(url?.port ?? 6379)
        self.password = url?.password ?? ""
    }

    func setValue(_ value: String, for key: String) {
        self.connect { (isSuccess) in
            guard isSuccess else {
                return
            }
            self.redis.set(key, value: value, callback: { (result, redisError) in
                if let error = redisError {
                    print(error)
                }
            })
        }
    }

    func getValue(for key: String, completion: @escaping (String?) -> Void) {
        self.connect { (isSuccess) in
            guard isSuccess else {
                return completion(nil)
            }
            self.redis.get(key, callback: { (result, redisError) in
                if let error = redisError {
                    print(error)
                }
                completion(result?.asString)
            })
        }
    }

    private func connect(completion: @escaping (Bool) -> Void) {
        redis.connect(host: host, port: port) { (redisError) in
            if let error = redisError {
                print(error)
                completion(false)
            } else {
                redis.auth(password) { (redisError) in
                    if let error = redisError {
                        // No password set is also an error
                        print(error.localizedDescription)
                    }
                    completion(true)
                }
            }
        }
    }

}
