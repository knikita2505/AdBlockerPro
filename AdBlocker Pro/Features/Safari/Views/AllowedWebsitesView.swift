import SwiftUI

struct AllowedWebsitesView: View {

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
                Text("Websites in this list will not be affected by content blocking rules")
            }

            Section {
                if contentBlocker.allowedWebsites.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: AppTheme.spacingS) {
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                                .foregroundStyle(AppTheme.secondaryText)
                            Text("No allowed websites yet")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(.vertical, AppTheme.spacingL)
                        Spacer()
                    }
                } else {
                    ForEach(contentBlocker.allowedWebsites, id: \.self) { domain in
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(AppTheme.accent)
                            Text(domain)
                                .font(AppTheme.bodyFont)
                        }
                    }
                    .onDelete { offsets in
                        contentBlocker.removeAllowedWebsite(at: offsets)
                    }
                }
            } header: {
                Text("Allowed Websites (\(contentBlocker.allowedWebsites.count))")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Allowed Websites")
        .alert("Invalid Domain", isPresented: $showInvalidDomainAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid domain name (e.g. example.com)")
        }
    }

    private func addWebsite() {
        guard subscriptionManager.requirePremium(for: .allowedWebsites) else { return }
        let normalized = newDomain.normalizedDomain
        guard normalized.isValidDomain else {
            showInvalidDomainAlert = true
            return
        }
        contentBlocker.addAllowedWebsite(normalized)
        newDomain = ""
        isTextFieldFocused = false
        HapticManager.notification(.success)
    }
}

#Preview {
    NavigationStack {
        AllowedWebsitesView()
    }
}
