//
//  AIProxyBackgroundTaskManager.swift
//
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation

#if canImport(UIKit)
import UIKit
import BackgroundTasks
#endif

/// Manages background tasks and network sessions for AIProxy services
public class AIProxyBackgroundTaskManager {
    
    public static let shared = AIProxyBackgroundTaskManager()
    
    #if canImport(UIKit)
    private var backgroundTaskIdentifiers: Set<UIBackgroundTaskIdentifier> = []
    #endif
    private let queue = DispatchQueue(label: "com.aiproxy.background", qos: .background)
    
    private init() {}
    
    /// Starts a background task to keep the app alive during network operations
    #if canImport(UIKit)
    public func startBackgroundTask(name: String = "AIProxy Network Task") -> UIBackgroundTaskIdentifier {
        var identifier: UIBackgroundTaskIdentifier = .invalid
        
        identifier = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            self?.endBackgroundTask(identifier: identifier)
        }
        
        queue.async {
            self.backgroundTaskIdentifiers.insert(identifier)
        }
        
        logIf(.debug)?.debug("Started background task: \(name) with identifier: \(identifier.rawValue)")
        return identifier
    }
    #else
    public func startBackgroundTask(name: String = "AIProxy Network Task") -> Int {
        logIf(.debug)?.debug("Started background task: \(name) (macOS - no background task needed)")
        return 0
    }
    #endif
    
    /// Ends a specific background task
    #if canImport(UIKit)
    public func endBackgroundTask(identifier: UIBackgroundTaskIdentifier) {
        queue.async {
            self.backgroundTaskIdentifiers.remove(identifier)
        }
        
        UIApplication.shared.endBackgroundTask(identifier)
        logIf(.debug)?.debug("Ended background task with identifier: \(identifier.rawValue)")
    }
    #else
    public func endBackgroundTask(identifier: Int) {
        logIf(.debug)?.debug("Ended background task (macOS - no background task needed)")
    }
    #endif
    
    /// Ends all active background tasks
    public func endAllBackgroundTasks() {
        #if canImport(UIKit)
        queue.async {
            let identifiers = self.backgroundTaskIdentifiers
            self.backgroundTaskIdentifiers.removeAll()
            
            DispatchQueue.main.async {
                for identifier in identifiers {
                    UIApplication.shared.endBackgroundTask(identifier)
                }
            }
        }
        #else
        logIf(.debug)?.debug("Ended all background tasks (macOS - no background tasks needed)")
        #endif
    }
    
    /// Performs a network operation with proper background task management
    public func performBackgroundNetworkOperation<T>(
        operation: @escaping () async throws -> T,
        taskName: String = "AIProxy Network Operation"
    ) async throws -> T {
        #if canImport(UIKit)
        let backgroundTaskId = startBackgroundTask(name: taskName)
        
        defer {
            endBackgroundTask(identifier: backgroundTaskId)
        }
        #endif
        
        do {
            let result = try await operation()
            logIf(.debug)?.debug("Background network operation completed successfully")
            return result
        } catch {
            logIf(.error)?.error("Background network operation failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Configures background app refresh for AIProxy services
    public func configureBackgroundAppRefresh() {
        #if canImport(UIKit)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.aiproxy.refresh", using: nil) { task in
            self.handleBackgroundAppRefresh(task: task as! BGAppRefreshTask)
        }
        #else
        logIf(.debug)?.debug("Background app refresh not available on macOS")
        #endif
    }
    
    /// Schedules background app refresh
    public func scheduleBackgroundAppRefresh() {
        #if canImport(UIKit)
        let request = BGAppRefreshTaskRequest(identifier: "com.aiproxy.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logIf(.debug)?.debug("Scheduled background app refresh")
        } catch {
            logIf(.error)?.error("Could not schedule background app refresh: \(error.localizedDescription)")
        }
        #else
        logIf(.debug)?.debug("Background app refresh not available on macOS")
        #endif
    }
    
    #if canImport(UIKit)
    private func handleBackgroundAppRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            logIf(.debug)?.debug("Background app refresh task expired")
        }
        
        // Perform your background AI operations here
        Task {
            do {
                // Example: Perform some background AI operation
                logIf(.debug)?.debug("Performing background app refresh operations")
                
                // Simulate some work
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                task.setTaskCompleted(success: true)
                logIf(.debug)?.debug("Background app refresh completed successfully")
            } catch {
                task.setTaskCompleted(success: false)
                logIf(.error)?.error("Background app refresh failed: \(error.localizedDescription)")
            }
        }
    }
    #endif
}
