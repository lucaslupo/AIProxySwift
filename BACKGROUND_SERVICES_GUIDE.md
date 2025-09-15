# Background Service Usage Guide

This guide explains how to use AIProxySwift's background services to make ChatGPT and other AI API calls when your app is in the background.

## Overview

The background services use `URLSessionConfiguration.background` instead of `.ephemeral` to enable background execution. This allows your app to continue making API requests even when it's not in the foreground.

## Setup Requirements

### 1. App Configuration

Add background modes to your app's `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>background-fetch</string>
</array>
```

### 2. App Delegate Implementation

Implement background session handling in your `AppDelegate`:

```swift
import AIProxy

class AppDelegate: UIResponder, UIApplicationDelegate {

    // Store completion handlers for background sessions
    private var backgroundCompletionHandlers: [String: () -> Void] = [:]

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Store the completion handler
        backgroundCompletionHandlers[identifier] = completionHandler

        // Set up the completion handler on the appropriate delegate
        if identifier.contains("openai") {
            AIProxyURLSession.backgroundDelegate.backgroundCompletionHandler = completionHandler
        } else if identifier.contains("anthropic") {
            AIProxyURLSession.backgroundDelegate.backgroundCompletionHandler = completionHandler
        }
    }
}
```

## Usage Examples

### OpenAI Background Service

```swift
import AIProxy

// Create a background OpenAI service
let openAIService = AIProxy.openAIBackgroundService(
    partialKey: "your-partial-key",
    serviceURL: "https://api.aiproxy.pro",
    backgroundSessionIdentifier: "com.yourapp.openai.background",
    clientID: "optional-client-id"
)

// Make a chat completion request
let request = OpenAIChatCompletionRequestBody(
    model: "gpt-4",
    messages: [
        OpenAIChatCompletionMessage(role: .user, content: "Hello, how are you?")
    ]
)

do {
    let response = try await openAIService.chatCompletion(request: request)
    print("Response: \(response.choices.first?.message.content ?? "No response")")
} catch {
    print("Error: \(error)")
}
```

### Anthropic Background Service

```swift
import AIProxy

// Create a background Anthropic service
let anthropicService = AIProxy.anthropicBackgroundService(
    partialKey: "your-partial-key",
    serviceURL: "https://api.aiproxy.pro",
    backgroundSessionIdentifier: "com.yourapp.anthropic.background",
    clientID: "optional-client-id"
)

// Make a message request
let request = AnthropicMessageRequestBody(
    model: "claude-3-sonnet-20240229",
    maxTokens: 1000,
    messages: [
        AnthropicMessage(role: .user, content: "Hello, how are you?")
    ]
)

do {
    let response = try await anthropicService.messageRequest(body: request)
    print("Response: \(response.content.first?.text ?? "No response")")
} catch {
    print("Error: \(error)")
}
```

### Background Task Integration

For iOS apps, integrate with background tasks:

```swift
import BackgroundTasks

class BackgroundTaskManager {

    func scheduleBackgroundAIRequest() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.ai-refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }

    func handleBackgroundAIRequest(task: BGAppRefreshTask) {
        // Set expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Perform AI request
        Task {
            do {
                let openAIService = AIProxy.openAIBackgroundService(
                    partialKey: "your-partial-key",
                    serviceURL: "https://api.aiproxy.pro",
                    backgroundSessionIdentifier: "com.yourapp.openai.background"
                )

                let request = OpenAIChatCompletionRequestBody(
                    model: "gpt-4",
                    messages: [
                        OpenAIChatCompletionMessage(role: .user, content: "Process background data")
                    ]
                )

                let response = try await openAIService.chatCompletion(request: request)
                print("Background AI response: \(response.choices.first?.message.content ?? "No response")")

                task.setTaskCompleted(success: true)
            } catch {
                print("Background AI request failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }
}
```

## Important Notes

1. **Session Identifiers**: Each background session must have a unique identifier. Use reverse domain notation (e.g., `com.yourapp.service.background`).

2. **Completion Handlers**: Background sessions require proper completion handler management. The system will relaunch your app if needed to handle background events.

3. **Certificate Pinning**: Background services maintain the same security features as regular services, including certificate pinning.

4. **DNS over TLS**: Background services support DNS over TLS configuration for enhanced privacy.

5. **Error Handling**: Background requests may fail due to network conditions or system limitations. Always implement proper error handling.

6. **Resource Management**: Background sessions consume system resources. Use them judiciously and clean up when appropriate.

## Troubleshooting

- **Session Not Working**: Ensure your app has the correct background modes enabled in Info.plist
- **Completion Handler Not Called**: Verify that you've properly implemented the AppDelegate method for background session events
- **Certificate Pinning Issues**: Background sessions use the same certificate pinning as regular sessions
- **Network Timeouts**: Background requests may have different timeout behavior than foreground requests

## Migration from Regular Services

To migrate from regular services to background services:

1. Replace `AIProxy.openAIService()` with `AIProxy.openAIBackgroundService()`
2. Replace `AIProxy.anthropicService()` with `AIProxy.anthropicBackgroundService()`
3. Add the required AppDelegate implementation
4. Update your Info.plist with background modes
5. Test thoroughly in background scenarios
