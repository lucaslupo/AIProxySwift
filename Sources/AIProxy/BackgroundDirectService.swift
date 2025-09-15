//
//  BackgroundDirectService.swift
//
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation

protocol BackgroundDirectService: ServiceMixin {
    var backgroundSessionIdentifier: String { get }
}

extension BackgroundDirectService {
    var urlSession: URLSession {
        return AIProxyUtils.directBackgroundURLSession(identifier: backgroundSessionIdentifier)
    }
}
