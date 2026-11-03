import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    private static let appGroupIdentifier = "group.nikita.ka.AdBlocker-Pro.ContentBlockerExt"
    private static let rulesFileName = "blockerList.json"

    private static let noopRules = "[{\"trigger\":{\"url-filter\":\"://never\\\\.match\\\\.this\\\\.domain\\\\.invalid\"},\"action\":{\"type\":\"block\"}}]"

    func beginRequest(with context: NSExtensionContext) {
        let attachment: NSItemProvider

        if let rulesURL = rulesFileURL(), FileManager.default.fileExists(atPath: rulesURL.path) {
            attachment = NSItemProvider(contentsOf: rulesURL)!
        } else {
            let data = Self.noopRules.data(using: .utf8)!
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("blockerList.json")
            try? data.write(to: tempURL)
            attachment = NSItemProvider(contentsOf: tempURL)!
        }

        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }

    private func rulesFileURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier)?
            .appendingPathComponent(Self.rulesFileName)
    }
}
