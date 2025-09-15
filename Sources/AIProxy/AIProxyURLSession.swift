//
//  AIProxyURLSession.swift
//
//
//  Created by Lou Zell on 8/5/24.
//

import Foundation

public enum AIProxyURLSession {
    public static var delegate = AIProxyCertificatePinningDelegate()
    public static var backgroundDelegate = AIProxyCertificatePinningDelegate()

    /// Creates a URLSession that is configured for communication with aiproxy.pro
    static func create() -> URLSession {
        return URLSession(
            configuration: .ephemeral,
            delegate: self.delegate,
            delegateQueue: nil
        )
    }
    
    /// Creates a URLSession that supports background execution for communication with aiproxy.pro
    static func createBackgroundSession(identifier: String = "com.aiproxy.background") -> URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sessionSendsLaunchEvents = true
        configuration.isDiscretionary = false
        
        return URLSession(
            configuration: configuration,
            delegate: self.backgroundDelegate,
            delegateQueue: nil
        )
    }

}
