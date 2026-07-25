// SOURCE: proven in a shipped production app.
//
// Four focused pages: promise, input, payoff, trust. At least two pages
// contain a real interaction that previews the app's value without asking for
// permissions or user data. The wizard rewrites the copy and demo content from
// DECISIONS/010-first-sixty-seconds.md.

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0
    @State private var selectedChoice = 0
    @State private var didTryDemo = false

    private let pageCount = 4
    private let choiceKeys = [
        "onboarding.demo.choice.1",
        "onboarding.demo.choice.2",
        "onboarding.demo.choice.3"
    ]

    var body: some View {
        ThemeRootView {
            VStack(spacing: 0) {
                topBar
                TabView(selection: $page) {
                    onboardingPage(
                        symbol: "sparkles",
                        titleKey: "onboarding.1.title",
                        bodyKey: "onboarding.1.body"
                    ) { promiseArt }
                    .tag(0)

                    onboardingPage(
                        symbol: "hand.tap",
                        titleKey: "onboarding.2.title",
                        bodyKey: "onboarding.2.body"
                    ) { choiceDemo }
                    .tag(1)

                    onboardingPage(
                        symbol: "wand.and.stars",
                        titleKey: "onboarding.3.title",
                        bodyKey: "onboarding.3.body"
                    ) { payoffDemo }
                    .tag(2)

                    onboardingPage(
                        symbol: "checkmark.shield",
                        titleKey: "onboarding.4.title",
                        bodyKey: "onboarding.4.body"
                    ) { trustArt }
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .motionSafeAnimation(.easeInOut, value: page)
                .onChange(of: page) { _, _ in
                    AccessibilityNotification.Announcement(progressLabel).post()
                }
                footer
            }
            .background(AppTheme.surface.ignoresSafeArea())
        }
    }

    private var topBar: some View {
        HStack {
            if page > 0 {
                Button { page -= 1 } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(Text("onboarding.previous"))
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            Spacer()
            Button("onboarding.skip", action: onComplete)
                .font(Typography.captionEmphasized)
                .frame(minWidth: 44, minHeight: 44)
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var footer: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? AppTheme.accent : AppTheme.surfaceTertiary)
                        .frame(width: index == page ? 28 : 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: progressLabel))

            Button(action: advance) {
                Label(
                    page == pageCount - 1 ? "onboarding.get_started" : "onboarding.next",
                    systemImage: page == pageCount - 1 ? "sparkles" : "arrow.right"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.seed)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }

    private var promiseArt: some View {
        HStack(spacing: Spacing.md) {
            ForEach(["sparkles", "hand.tap", "checkmark.seal"], id: \.self) { symbol in
                Image(systemName: symbol)
                    .font(IconSize.medium)
                    .foregroundStyle(AppTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 96)
                    .background(RoundedRectangle(cornerRadius: 20).fill(AppTheme.surfaceSecondary))
                    .accessibilityHidden(true)
            }
        }
    }

    private var choiceDemo: some View {
        HStack(spacing: Spacing.md) {
            ForEach(0..<3, id: \.self) { index in
                Button {
                    selectedChoice = index
                } label: {
                    Image(systemName: ["circle.fill", "square.fill", "triangle.fill"][index])
                        .font(IconSize.medium)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedChoice == index ? AppTheme.accent : AppTheme.surfaceSecondary)
                        )
                        .foregroundStyle(selectedChoice == index ? AppTheme.onAccent : AppTheme.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(LocalizedStringKey(choiceKeys[index])))
                .accessibilityAddTraits(selectedChoice == index ? .isSelected : [])
            }
        }
    }

    private var payoffDemo: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: didTryDemo ? "checkmark.circle.fill" : "wand.and.stars")
                .font(IconSize.hero)
                .foregroundStyle(AppTheme.accent)
                .contentTransition(.symbolEffect(.replace))
            Button(didTryDemo ? "onboarding.demo.done" : "onboarding.demo.try") {
                didTryDemo = true
            }
            .buttonStyle(.seed)
            .disabled(didTryDemo)
        }
        .frame(maxWidth: .infinity, minHeight: 210)
        .background(RoundedRectangle(cornerRadius: 24).fill(AppTheme.surfaceSecondary))
    }

    private var trustArt: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "iphone.gen3")
                .font(IconSize.hero)
                .foregroundStyle(AppTheme.accent)
            Image(systemName: "lock.fill")
                .foregroundStyle(AppTheme.onSurfaceSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 210)
        .background(RoundedRectangle(cornerRadius: 24).fill(AppTheme.surfaceSecondary))
        .accessibilityHidden(true)
    }

    private func onboardingPage<Content: View>(
        symbol: String,
        titleKey: LocalizedStringKey,
        bodyKey: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        AdaptiveOnboardingPage(
            symbol: symbol,
            title: Text(titleKey),
            detail: Text(bodyKey),
            content: content()
        )
    }

    private func advance() {
        if page == pageCount - 1 {
            onComplete()
        } else {
            page += 1
        }
    }

    private var progressLabel: String {
        String(
            format: String(localized: "onboarding.progress"),
            page + 1,
            pageCount
        )
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
