//
//  BackgroundProxiedService.swift
//
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation

protocol BackgroundProxiedService: ServiceMixin {
    var backgroundSessionIdentifier: String { get }
}

extension BackgroundProxiedService {
    var urlSession: URLSession {
        return AIProxyUtils.proxiedBackgroundURLSession(identifier: backgroundSessionIdentifier)
    }
}
