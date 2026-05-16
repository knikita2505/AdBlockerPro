import Foundation

extension String {

    var isValidDomain: Bool {
        let pattern = #"^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var normalizedDomain: String {
        var domain = lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if domain.hasPrefix("https://") { domain = String(domain.dropFirst(8)) }
        if domain.hasPrefix("http://") { domain = String(domain.dropFirst(7)) }
        if domain.hasPrefix("www.") { domain = String(domain.dropFirst(4)) }
        if domain.hasSuffix("/") { domain = String(domain.dropLast()) }
        return domain
    }
}
