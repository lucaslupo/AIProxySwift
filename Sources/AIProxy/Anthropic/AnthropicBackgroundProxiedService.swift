//
//  AnthropicBackgroundProxiedService.swift
//
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation

open class AnthropicBackgroundProxiedService: AnthropicService, BackgroundProxiedService {
    private let partialKey: String
    private let serviceURL: String
    private let clientID: String?
    let backgroundSessionIdentifier: String

    /// This initializer is not public on purpose.
    /// Customers are expected to use the factory `AIProxy.anthropicBackgroundService` defined in AIProxy.swift
    internal init(
        partialKey: String,
        serviceURL: String,
        clientID: String?,
        backgroundSessionIdentifier: String
    ) {
        self.partialKey = partialKey
        self.serviceURL = serviceURL
        self.clientID = clientID
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
    }

    /// Initiates a non-streaming request to /v1/messages.
    ///
    /// - Parameters:
    ///   - body: The message request body. See this reference:
    ///                         https://docs.anthropic.com/en/api/messages
    /// - Returns: The message response body, See this reference:
    ///            https://platform.openai.com/docs/api-reference/chat/object
    public func messageRequest(
        body: AnthropicMessageRequestBody
    ) async throws -> AnthropicMessageResponseBody {
        var body = body
        body.stream = false
        var additionalHeaders = [
            "anthropic-version": "2023-06-01",
        ]
        if body.needsPDFBeta {
            additionalHeaders["anthropic-beta"] = "pdfs-2024-09-25"
        }
        let request = try await AIProxyURLRequest.create(
            partialKey: self.partialKey,
            serviceURL: self.serviceURL,
            clientID: self.clientID,
            proxyPath: "/v1/messages",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: 60,
            contentType: "application/json",
            additionalHeaders: additionalHeaders
        )
        return try await self.makeRequestAndDeserializeResponse(request)
    }

    /// Initiates a streaming request to /v1/messages.
    ///
    /// - Parameters:
    ///   - body: The message request body. See this reference:
    ///                         https://docs.anthropic.com/en/api/messages
    /// - Returns: The message response body, See this reference:
    ///            https://platform.openai.com/docs/api-reference/chat/object
    public func streamingMessageRequest(
        body: AnthropicMessageRequestBody
    ) async throws -> AnthropicAsyncChunks {
        var body = body
        body.stream = true
        var additionalHeaders = [
            "anthropic-version": "2023-06-01",
        ]
        if body.needsPDFBeta {
            additionalHeaders["anthropic-beta"] = "pdfs-2024-09-25"
        }
        let request = try await AIProxyURLRequest.create(
            partialKey: self.partialKey,
            serviceURL: self.serviceURL,
            clientID: self.clientID,
            proxyPath: "/v1/messages",
            body: try body.serialize(),
            verb: .post,
            secondsToWait: 60,
            contentType: "application/json",
            additionalHeaders: additionalHeaders
        )
        let (asyncBytes, _) = try await BackgroundNetworker.makeRequestAndWaitForAsyncBytes(self.urlSession, request)
        return AnthropicAsyncChunks(asyncLines: asyncBytes.lines)
    }
}
