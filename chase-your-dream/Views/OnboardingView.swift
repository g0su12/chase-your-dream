import SwiftUI

private enum OnboardingStep: Int, CaseIterable {
    case warmWelcome
    case empathyCheckIn
    case noPressureRule
    case firstMicroWin
}

private enum EmpathyChoice: String, CaseIterable, Identifiable {
    case exhausted
    case lost
    case motivation
    case calm

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.exhausted, .vi):
            return "Tôi thấy kiệt sức và mệt mỏi."
        case (.lost, .vi):
            return "Tôi đang hơi mông lung và lạc lối."
        case (.motivation, .vi):
            return "Tôi cần một chút động lực để bước tiếp."
        case (.calm, .vi):
            return "Tôi chỉ muốn tìm một chốn bình yên."
        case (.exhausted, .en):
            return "I feel exhausted and drained."
        case (.lost, .en):
            return "I feel a little lost and uncertain."
        case (.motivation, .en):
            return "I need a little motivation to keep moving."
        case (.calm, .en):
            return "I just want a peaceful place to breathe."
        }
    }
}

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppStorageKeys.onboardingEmotion) private var onboardingEmotionRaw: String = ""

    let language: AppLanguage
    let onStart: () -> Void

    @State private var step: OnboardingStep = .warmWelcome
    @State private var selectedChoice: EmpathyChoice?
    @State private var showWelcomeText = false
    @State private var showWelcomeContinue = false
    @State private var showEmpathyToast = false
    @State private var microWinAction = ""
    @State private var confettiTrigger = 0
    @State private var isFinishingFlow = false

    var body: some View {
        ZStack {
            HealingTheme.screenBackground(for: colorScheme)
                .ignoresSafeArea()

            ambientShapes

            VStack {
                Spacer(minLength: 24)

                stepView

                Spacer(minLength: 18)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 30)

            if step == .empathyCheckIn, showEmpathyToast {
                empathyToast
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
            }

            PastelConfettiLayer(trigger: confettiTrigger)
                .allowsHitTesting(false)
        }
        .tint(HealingTheme.primaryAccent(for: colorScheme))
        .animation(.easeInOut(duration: 0.35), value: step)
        .onAppear {
            if let restored = EmpathyChoice(rawValue: onboardingEmotionRaw) {
                selectedChoice = restored
            }
            prepareWelcomeStep()
            prepareMicroWinIfNeeded()
        }
        .onChange(of: step) { newStep in
            if newStep == .warmWelcome {
                prepareWelcomeStep()
            }
            if newStep == .firstMicroWin {
                prepareMicroWinIfNeeded(forceRefresh: true)
            }
        }
    }

    private var ambientShapes: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.83, green: 0.91, blue: 0.84).opacity(colorScheme == .dark ? 0.12 : 0.36))
                .frame(width: 260, height: 260)
                .offset(x: -140, y: -250)

            Circle()
                .fill(Color(red: 0.98, green: 0.80, blue: 0.69).opacity(colorScheme == .dark ? 0.10 : 0.34))
                .frame(width: 240, height: 240)
                .offset(x: 150, y: 260)

            RoundedRectangle(cornerRadius: 140, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.04 : 0.35))
                .frame(width: 380, height: 160)
                .blur(radius: 20)
                .offset(y: -60)
        }
        .allowsHitTesting(false)
    }

    private var heroIllustration: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.52))
                .frame(width: 208, height: 208)

            VStack(spacing: 12) {
                SunDoodleIllustration()
                    .scaleEffect(1.28)

                WaveDoodleIllustration()
                    .opacity(colorScheme == .dark ? 0.32 : 0.56)
            }
        }
    }

    @ViewBuilder
    private var stepView: some View {
        switch step {
        case .warmWelcome:
            warmWelcomeStep
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
        case .empathyCheckIn:
            empathyCheckInStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .noPressureRule:
            noPressureRuleStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .firstMicroWin:
            firstMicroWinStep
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }

    private var warmWelcomeStep: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 8)

            Text(localized(vi: "Chào bạn. Thật vui vì hôm nay bạn đã ở đây.", en: "Hi there. I am glad you are here today."))
                .font(.system(size: 34, weight: .medium, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 12)
                .opacity(showWelcomeText ? 1 : 0)
                .scaleEffect(showWelcomeText ? 1 : 0.94)

            Spacer()

            if showWelcomeContinue {
                onboardingButton(
                    title: localized(vi: "Tiếp tục", en: "Continue"),
                    style: .secondary,
                    action: { moveToStep(.empathyCheckIn) }
                )
                .transition(.opacity)
            }
        }
    }

    private var empathyCheckInStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localized(vi: "Dạo này bạn cảm thấy thế nào?", en: "How have you been feeling lately?"))
                .font(.system(size: 32, weight: .semibold, design: .rounded))

            VStack(spacing: 10) {
                ForEach(EmpathyChoice.allCases) { choice in
                    Button {
                        chooseEmpathy(choice)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Text(choice.title(language: language))
                                .font(.body)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: 0)

                            if selectedChoice == choice {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(selectedChoice == choice ? 0.82 : 0.64))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selectedChoice == choice
                                                ? HealingTheme.primaryAccent(for: colorScheme).opacity(0.55)
                                                : Color.black.opacity(0.08),
                                            lineWidth: selectedChoice == choice ? 1.6 : 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 6)

            onboardingButton(
                title: localized(vi: "Tiếp tục", en: "Continue"),
                style: .primary,
                isDisabled: selectedChoice == nil,
                action: { moveToStep(.noPressureRule) }
            )
        }
    }

    private var noPressureRuleStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localized(vi: "Ở đây, chúng ta không có áp lực.", en: "Here, we do not carry pressure."))
                .font(.system(size: 32, weight: .semibold, design: .rounded))

            Text(
                localized(
                    vi: "Bạn không cần phải ngay lập tức chạy cả một chặng marathon dài hay hoàn thành những dự án khổng lồ. Hãy bắt đầu bằng những việc nhỏ xíu: vuốt ve một chú cún cưng, uống một ngụm nước đầy, hay chỉ đơn giản là hít một hơi thật sâu. Mọi nỗ lực nhỏ đều đáng tự hào.",
                    en: "You do not need to run a marathon or finish huge projects right away. Start with tiny actions: pet a dog, drink a full sip of water, or take one deep breath. Every small effort is worth being proud of."
                )
            )
            .font(.body)
            .foregroundStyle(.secondary)
            .lineSpacing(4)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.62))
            )

            Spacer(minLength: 6)

            onboardingButton(
                title: localized(vi: "Tôi đồng ý", en: "I agree"),
                style: .primary,
                action: { moveToStep(.firstMicroWin) }
            )
        }
    }

    private var firstMicroWinStep: some View {
        VStack(spacing: 18) {
            Text(localized(vi: "Trước khi bắt đầu, hãy thử làm một việc nhỏ này nhé:", en: "Before we begin, try this tiny action:"))
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            Text(microWinAction)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.66))
                )

            Spacer(minLength: 8)

            Button {
                completeFirstWin()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.76, blue: 0.66),
                                    Color(red: 0.93, green: 0.67, blue: 0.57)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Circle()
                        .stroke(Color.white.opacity(0.45), lineWidth: 3)
                        .padding(10)

                    Text(localized(vi: "Mình làm được rồi", en: "I did it"))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                .frame(width: 190, height: 190)
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.30 : 0.14),
                    radius: 12,
                    x: 0,
                    y: 8
                )
            }
            .buttonStyle(.plain)
            .disabled(isFinishingFlow)
            .scaleEffect(isFinishingFlow ? 0.97 : 1)

            Spacer(minLength: 2)
        }
    }

    private var empathyToast: some View {
        VStack {
            Spacer()

            Text(
                localized(
                    vi: "Không sao đâu, cảm thấy mệt mỏi là điều rất bình thường. Chúng ta sẽ đi từng bước một nhé.",
                    en: "It is okay to feel tired. We will go one gentle step at a time."
                )
            )
            .font(.subheadline)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.20 : 0.90))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    private func onboardingButton(
        title: String,
        style: OnboardingButtonStyle,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(style == .primary ? primaryButtonGradient : secondaryButtonFill)
                )
                .foregroundStyle(style == .primary ? Color.white : Color.primary)
                .shadow(
                    color: style == .primary
                        ? Color.black.opacity(colorScheme == .dark ? 0.30 : 0.12)
                        : Color.clear,
                    radius: 12,
                    x: 0,
                    y: 8
                )
        }
        .buttonStyle(.plain)
        .opacity(isDisabled ? 0.45 : 1)
        .disabled(isDisabled)
    }

    private var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.74, blue: 0.63),
                Color(red: 0.95, green: 0.66, blue: 0.56)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var secondaryButtonFill: LinearGradient {
        let color = Color.white.opacity(colorScheme == .dark ? 0.16 : 0.74)
        return LinearGradient(
            colors: [color, color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func moveToStep(_ newStep: OnboardingStep) {
        withAnimation(.easeInOut(duration: 0.35)) {
            step = newStep
        }
    }

    private func prepareWelcomeStep() {
        showWelcomeText = false
        showWelcomeContinue = false

        withAnimation(.easeOut(duration: 0.8)) {
            showWelcomeText = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard step == .warmWelcome else { return }
            withAnimation(.easeInOut(duration: 0.45)) {
                showWelcomeContinue = true
            }
        }
    }

    private func chooseEmpathy(_ choice: EmpathyChoice) {
        selectedChoice = choice
        onboardingEmotionRaw = choice.rawValue

        withAnimation(.easeInOut(duration: 0.25)) {
            showEmpathyToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            guard step == .empathyCheckIn else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                showEmpathyToast = false
            }
        }
    }

    private func prepareMicroWinIfNeeded(forceRefresh: Bool = false) {
        if !microWinAction.isEmpty, !forceRefresh { return }

        let suggestionsVi = [
            "Thả lỏng hai vai của bạn xuống nào.",
            "Mỉm cười trong 3 giây nhé.",
            "Rời mắt khỏi màn hình và nhìn ra xa một chút."
        ]

        let suggestionsEn = [
            "Let your shoulders drop and relax.",
            "Give yourself a 3-second smile.",
            "Look away from the screen and gaze far for a moment."
        ]

        let source = language == .vi ? suggestionsVi : suggestionsEn
        microWinAction = source.randomElement() ?? source[0]
    }

    private func completeFirstWin() {
        guard !isFinishingFlow else { return }

        isFinishingFlow = true
        confettiTrigger += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            onStart()
        }
    }

    private func localized(vi: String, en: String) -> String {
        language == .vi ? vi : en
    }
}

private enum OnboardingButtonStyle {
    case primary
    case secondary
}

private struct PastelConfettiLayer: View {
    let trigger: Int

    @State private var pieces: [PastelConfettiPiece] = []
    @State private var hasBurst = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    Group {
                        if piece.isCapsule {
                            Capsule(style: .continuous)
                                .fill(piece.color)
                        } else {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(piece.color)
                        }
                    }
                    .frame(
                        width: piece.size,
                        height: piece.isCapsule ? piece.size * 0.55 : piece.size
                    )
                    .rotationEffect(.degrees(hasBurst ? piece.rotation : 0))
                    .position(
                        x: proxy.size.width * 0.5 + piece.startX + (hasBurst ? piece.driftX : 0),
                        y: proxy.size.height * 0.70 + (hasBurst ? piece.driftY : 0)
                    )
                    .opacity(hasBurst ? 0 : 1)
                }
            }
            .onChange(of: trigger) { _ in
                pieces = makePieces()
                hasBurst = false

                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 1.05)) {
                        hasBurst = true
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
                    pieces = []
                }
            }
        }
    }

    private func makePieces() -> [PastelConfettiPiece] {
        let colors = [
            Color(red: 0.97, green: 0.79, blue: 0.66),
            Color(red: 0.86, green: 0.92, blue: 0.78),
            Color(red: 0.73, green: 0.86, blue: 0.95),
            Color(red: 0.96, green: 0.74, blue: 0.82),
            Color(red: 0.93, green: 0.86, blue: 0.65)
        ]

        return (0..<34).map { _ in
            PastelConfettiPiece(
                startX: CGFloat.random(in: -24...24),
                driftX: CGFloat.random(in: -170...170),
                driftY: CGFloat.random(in: -250 ... -95),
                size: CGFloat.random(in: 6...11),
                rotation: Double.random(in: -180...180),
                color: colors.randomElement() ?? .white,
                isCapsule: Bool.random()
            )
        }
    }
}

private struct PastelConfettiPiece: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let driftX: CGFloat
    let driftY: CGFloat
    let size: CGFloat
    let rotation: Double
    let color: Color
    let isCapsule: Bool
}

#Preview {
    OnboardingView(language: .vi, onStart: {})
}
