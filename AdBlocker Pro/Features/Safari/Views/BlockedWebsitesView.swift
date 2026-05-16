import SwiftUI

struct BlockedWebsitesView: View {

    var contentBlocker = ContentBlockerManager.shared
    var subscriptionManager = SubscriptionManager.shared
    @State private var newDomain = ""
    @State private var showInvalidDomainAlert = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("example.com", text: $newDomain)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { addWebsite() }

                    Button(action: addWebsite) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.accent)
                    }
                    .disabled(newDomain.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Add Website")
            } footer: {
                Text("These websites will always be blocked regardless of other filter settings")
            }

            Section {
                if contentBlocker.blockedWebsites.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: AppTheme.spacingS) {
                            Image(systemName: "xmark.circle")
                                .font(.largeTitle)
                                .foregroundStyle(AppTheme.secondaryText)
                            Text("No blocked websites yet")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(.vertical, AppTheme.spacingL)
                        Spacer()
                    }
                } else {
                    ForEach(contentBlocker.blockedWebsites, id: \.self) { domain in
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(AppTheme.destructive)
                            Text(domain)
                                .font(AppTheme.bodyFont)
                        }
                    }
                    .onDelete { offsets in
                        contentBlocker.removeBlockedWebsite(at: offsets)
                    }
                }
            } header: {
                Text("Blocked Websites (\(contentBlocker.blockedWebsites.count))")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Blocked Websites")
        .alert("Invalid Domain", isPresented: $showInvalidDomainAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid domain name (e.g. example.com)")
        }
    }

    private func addWebsite() {
        guard subscriptionManager.requirePremium(for: .blockedWebsites) else { return }
        let normalized = newDomain.normalizedDomain
        guard normalized.isValidDomain else {
            showInvalidDomainAlert = true
            return
        }
        contentBlocker.addBlockedWebsite(normalized)
        newDomain = ""
        isTextFieldFocused = false
        HapticManager.notification(.success)
    }
}

#Preview {
    NavigationStack {
        BlockedWebsitesView()
    }
}
