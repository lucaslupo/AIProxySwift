//
//  OpenAIBackgroundProxiedService.swift
//
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation

open class OpenAIBackgroundProxiedService: OpenAIService, BackgroundProxiedService {
    private let partialKey: String
    private let serviceURL: String
    private let clientID: String?
    private let requestFormat: OpenAIRequestFormat
    let backgroundSessionIdentifier: String

    /// This initializer is not public on purpose.
    /// Customers are expected to use the factory `AIProxy.openAIBackgroundService` defined in AIProxy.swift
    internal init(
        partialKey: String,
        serviceURL: String?,
        clientID: String?,
        requestFormat: OpenAIRequestFormat,
        backgroundSessionIdentifier: String
    ) {
        self.partialKey = partialKey
        self.serviceURL = serviceURL ?? "https://api.aiproxy.pro"
        self.clientID = clientID
        self.requestFormat = requestFormat
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        
        let requestBuilder = OpenAIProxiedRequestBuilder(
            partialKey: partialKey,
            serviceURL: self.serviceURL,
            clientID: clientID,
            requestFormat: requestFormat
        )
        super.init(
            requestFormat: requestFormat,
            requestBuilder: requestBuilder,
            serviceNetworker: BackgroundNetworker()
        )
    }
}
