import SwiftUI

struct SunDoodleIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.98, green: 0.84, blue: 0.55), Color(red: 0.97, green: 0.72, blue: 0.43)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 44, height: 44)

            ForEach(0..<8, id: \.self) { idx in
                Capsule()
                    .fill(Color(red: 0.93, green: 0.69, blue: 0.41).opacity(0.72))
                    .frame(width: 2, height: 10)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(idx) * 45))
            }

            Path { path in
                path.move(to: CGPoint(x: 8, y: 36))
                path.addCurve(to: CGPoint(x: 40, y: 36), control1: CGPoint(x: 18, y: 30), control2: CGPoint(x: 30, y: 42))
            }
            .stroke(Color(red: 0.31, green: 0.58, blue: 0.49).opacity(0.7), lineWidth: 2)
        }
        .frame(width: 72, height: 72)
    }
}

struct WaveDoodleIllustration: View {
    var body: some View {
        VStack(spacing: 5) {
            waveLine(opacity: 0.48, yOffset: 0)
            waveLine(opacity: 0.36, yOffset: 2)
            waveLine(opacity: 0.26, yOffset: 4)
        }
        .frame(width: 78, height: 44)
    }

    private func waveLine(opacity: Double, yOffset: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 12 + yOffset))
            path.addCurve(to: CGPoint(x: 24, y: 12 + yOffset), control1: CGPoint(x: 6, y: 4 + yOffset), control2: CGPoint(x: 14, y: 20 + yOffset))
            path.addCurve(to: CGPoint(x: 52, y: 12 + yOffset), control1: CGPoint(x: 32, y: 4 + yOffset), control2: CGPoint(x: 42, y: 20 + yOffset))
            path.addCurve(to: CGPoint(x: 78, y: 12 + yOffset), control1: CGPoint(x: 60, y: 4 + yOffset), control2: CGPoint(x: 70, y: 20 + yOffset))
        }
        .stroke(Color(red: 0.44, green: 0.70, blue: 0.83).opacity(opacity), lineWidth: 2.2)
    }
}

struct LeafCornerIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.clear)

            Path { path in
                path.move(to: CGPoint(x: 10, y: 24))
                path.addQuadCurve(to: CGPoint(x: 34, y: 6), control: CGPoint(x: 14, y: 8))
                path.addQuadCurve(to: CGPoint(x: 20, y: 30), control: CGPoint(x: 36, y: 28))
                path.closeSubpath()
            }
            .fill(Color(red: 0.66, green: 0.80, blue: 0.64).opacity(0.48))

            Path { path in
                path.move(to: CGPoint(x: 26, y: 14))
                path.addLine(to: CGPoint(x: 20, y: 24))
            }
            .stroke(Color(red: 0.41, green: 0.58, blue: 0.43).opacity(0.65), lineWidth: 1.2)
        }
        .frame(width: 42, height: 36)
    }
}

struct MoodPebbleRow: View {
    let values: [Int]
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: 10) {
            ForEach(values.indices, id: \.self) { idx in
                let mood = values[idx]
                MoodSceneIcon(mood: mood, size: size)
            }
        }
    }
}

struct AnimatedMoodSelector: View {
    @Binding var moodLevel: Int
    let language: AppLanguage
    let colorScheme: ColorScheme

    @State private var isBreathing = false

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { mood in
                    moodCard(for: mood)
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }

    private func moodCard(for mood: Int) -> some View {
        let selected = moodLevel == mood

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                moodLevel = mood
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    if selected {
                        MoodAura(color: moodColor(mood), isBreathing: isBreathing)
                    }

                    MoodSceneIcon(
                        mood: mood,
                        size: selected ? 62 : 50,
                        isActive: selected,
                        isBreathing: isBreathing
                    )
                }
                .frame(height: 70)

                VStack(spacing: 3) {
                    Text(moodTitle(mood))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(moodDetail(mood))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
            .frame(width: selected ? 116 : 92)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(selected ? moodTint(mood) : HealingTheme.panelBackground(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                selected
                                    ? moodColor(mood).opacity(colorScheme == .dark ? 0.52 : 0.42)
                                    : HealingTheme.cardStroke(for: colorScheme),
                                lineWidth: selected ? 1.35 : 0.8
                            )
                    )
            )
            .shadow(
                color: selected ? moodColor(mood).opacity(colorScheme == .dark ? 0.28 : 0.20) : Color.clear,
                radius: selected ? 12 : 0,
                x: 0,
                y: 7
            )
            .scaleEffect(selected && isBreathing ? 1.025 : 1)
        }
        .buttonStyle(.plain)
    }

    private func moodTitle(_ mood: Int) -> String {
        switch (mood, language) {
        case (1, .vi): return "Mệt"
        case (2, .vi): return "Nặng"
        case (3, .vi): return "Ở giữa"
        case (4, .vi): return "Nhẹ"
        case (5, .vi): return "Sáng"
        case (1, .en): return "Tired"
        case (2, .en): return "Heavy"
        case (3, .en): return "Middle"
        case (4, .en): return "Light"
        default: return language == .vi ? "Sáng" : "Bright"
        }
    }

    private func moodDetail(_ mood: Int) -> String {
        switch (mood, language) {
        case (1, .vi): return "đi thật chậm"
        case (2, .vi): return "cần dịu lại"
        case (3, .vi): return "đủ để bắt đầu"
        case (4, .vi): return "dễ thở hơn"
        case (5, .vi): return "có nắng nhỏ"
        case (1, .en): return "go slowly"
        case (2, .en): return "soften first"
        case (3, .en): return "enough to begin"
        case (4, .en): return "more ease"
        default: return language == .vi ? "có nắng nhỏ" : "small sunlight"
        }
    }

    private func moodTint(_ mood: Int) -> Color {
        moodColor(mood).opacity(colorScheme == .dark ? 0.24 : 0.22)
    }

    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1: return Color(red: 0.50, green: 0.64, blue: 0.74)
        case 2: return Color(red: 0.82, green: 0.67, blue: 0.50)
        case 3: return Color(red: 0.75, green: 0.73, blue: 0.66)
        case 4: return Color(red: 0.55, green: 0.73, blue: 0.58)
        default: return Color(red: 0.47, green: 0.72, blue: 0.82)
        }
    }
}

struct BloomProgressControl: View {
    @Binding var progress: Double
    let language: AppLanguage
    let colorScheme: ColorScheme

    @State private var isBreathing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(language == .vi ? "Mầm hôm nay" : "Today's Bloom")
                        .font(.subheadline.weight(.semibold))

                    Text(progressCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(progress))%")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                    .contentTransition(.numericText())
            }

            HStack(alignment: .top, spacing: 7) {
                ForEach(0..<5, id: \.self) { index in
                    bloomStageButton(index: index)
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.78), value: selectedStage)

            HStack(spacing: 8) {
                Image(systemName: progressIcon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))

                Text(progressHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }

    private var selectedStage: Int {
        let clamped = min(max(progress, 0), 100)
        return min(max(Int((clamped / 25).rounded()), 0), 4)
    }

    private func bloomStageButton(index: Int) -> some View {
        let selected = index == selectedStage
        let reached = index <= selectedStage
        let stageColor = bloomColor(for: index)

        return Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                progress = Double(index) * 25
            }
        } label: {
            VStack(spacing: 7) {
                ZStack {
                    if selected {
                        MoodAura(color: stageColor, isBreathing: isBreathing)
                            .scaleEffect(0.74)
                    }

                    BloomStageIllustration(
                        stage: index,
                        isSelected: selected,
                        isReached: reached,
                        isBreathing: isBreathing,
                        colorScheme: colorScheme
                    )
                }
                .frame(height: 54)

                Text(stageTitle(for: index))
                    .font(.caption2.weight(selected ? .bold : .semibold))
                    .foregroundStyle(selected ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(selected ? stageColor.opacity(colorScheme == .dark ? 0.24 : 0.18) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                selected ? stageColor.opacity(colorScheme == .dark ? 0.56 : 0.40) : Color.secondary.opacity(0.10),
                                lineWidth: selected ? 1.2 : 0.8
                            )
                    )
            )
            .scaleEffect(selected && isBreathing ? 1.03 : 1)
        }
        .buttonStyle(.plain)
    }

    private func stageTitle(for index: Int) -> String {
        switch (index, language) {
        case (0, .vi): return "Hạt"
        case (1, .vi): return "Mầm"
        case (2, .vi): return "Lá"
        case (3, .vi): return "Nụ"
        case (4, .vi): return "Hoa"
        case (0, .en): return "Seed"
        case (1, .en): return "Sprout"
        case (2, .en): return "Leaf"
        case (3, .en): return "Bud"
        default: return language == .vi ? "Hoa" : "Bloom"
        }
    }

    private func bloomColor(for index: Int) -> Color {
        switch index {
        case 0: return Color(red: 0.76, green: 0.69, blue: 0.55)
        case 1: return Color(red: 0.58, green: 0.74, blue: 0.56)
        case 2: return Color(red: 0.48, green: 0.68, blue: 0.52)
        case 3: return Color(red: 0.70, green: 0.67, blue: 0.82)
        default: return Color(red: 0.88, green: 0.67, blue: 0.48)
        }
    }

    private var progressCaption: String {
        switch (selectedStage, language) {
        case (0, .vi):
            return "Chỉ cần gieo một hạt nhỏ."
        case (1, .vi):
            return "Mầm đang nhú lên rồi."
        case (2, .vi):
            return "Nhịp hôm nay đang xanh hơn."
        case (3, .vi):
            return "Một nụ nhỏ đang giữ nhịp."
        case (_, .vi):
            return "Một bông nhỏ đã nở."
        case (0, .en):
            return "Planting one small seed is enough."
        case (1, .en):
            return "A small sprout is showing."
        case (2, .en):
            return "Today is getting greener."
        case (3, .en):
            return "A small bud is keeping rhythm."
        default:
            return "A small bloom has opened."
        }
    }

    private var progressHint: String {
        switch language {
        case .vi:
            return "Chọn mức nở giống cảm giác hôm nay, không phải để tự chấm điểm."
        case .en:
            return "Choose the bloom stage that matches today, not a grade for yourself."
        }
    }

    private var progressIcon: String {
        switch selectedStage {
        case 0:
            return "circle.dotted"
        case 1:
            return "leaf"
        case 2:
            return "leaf.fill"
        case 3:
            return "camera.macro"
        default:
            return "sparkles"
        }
    }
}

private struct BloomStageIllustration: View {
    let stage: Int
    let isSelected: Bool
    let isReached: Bool
    let isBreathing: Bool
    let colorScheme: ColorScheme

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.20 : 0.74),
                            stageColor.opacity(isReached ? 0.92 : 0.30)
                        ],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: 34
                    )
                )
                .frame(width: isSelected ? 48 : 42, height: isSelected ? 48 : 42)

            stageArtwork
                .scaleEffect(isSelected && isBreathing ? 1.08 : 1)
        }
        .frame(width: 58, height: 58)
        .shadow(color: stageColor.opacity(isSelected ? 0.26 : 0.08), radius: isSelected ? 8 : 3, x: 0, y: 4)
    }

    @ViewBuilder
    private var stageArtwork: some View {
        switch stage {
        case 0:
            Circle()
                .fill(ink.opacity(isReached ? 0.58 : 0.28))
                .frame(width: 13, height: 13)
                .offset(y: 8)
        case 1:
            sprout(leaves: 1)
        case 2:
            sprout(leaves: 2)
        case 3:
            ZStack {
                sprout(leaves: 2)
                    .offset(y: 4)

                Circle()
                    .fill(ink.opacity(isReached ? 0.66 : 0.34))
                    .frame(width: 13, height: 13)
                    .offset(y: -10)
            }
        default:
            ZStack {
                ForEach(0..<6, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(ink.opacity(isReached ? 0.62 : 0.34))
                        .frame(width: 8, height: 17)
                        .offset(y: -11)
                        .rotationEffect(.degrees(Double(index) * 60))
                }

                Circle()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.70 : 0.88))
                    .frame(width: 11, height: 11)
            }
            .rotationEffect(.degrees(isBreathing ? 8 : -6))
        }
    }

    private func sprout(leaves: Int) -> some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(ink.opacity(isReached ? 0.62 : 0.32))
                .frame(width: 4, height: leaves == 1 ? 24 : 31)
                .offset(y: 8)

            HStack(spacing: -2) {
                LeafShape()
                    .fill(ink.opacity(isReached ? 0.62 : 0.34))
                    .frame(width: leaves == 1 ? 15 : 18, height: leaves == 1 ? 22 : 26)
                    .rotationEffect(.degrees(-34))

                if leaves > 1 {
                    LeafShape()
                        .fill(ink.opacity(isReached ? 0.54 : 0.30))
                        .frame(width: 16, height: 24)
                        .rotationEffect(.degrees(38))
                }
            }
            .offset(y: leaves == 1 ? -1 : -7)
        }
    }

    private var ink: Color {
        colorScheme == .dark ? Color.white : Color(red: 0.20, green: 0.34, blue: 0.25)
    }

    private var stageColor: Color {
        switch stage {
        case 0: return Color(red: 0.76, green: 0.69, blue: 0.55)
        case 1: return Color(red: 0.58, green: 0.74, blue: 0.56)
        case 2: return Color(red: 0.48, green: 0.68, blue: 0.52)
        case 3: return Color(red: 0.70, green: 0.67, blue: 0.82)
        default: return Color(red: 0.88, green: 0.67, blue: 0.48)
        }
    }
}

struct MoodSceneIcon: View {
    let mood: Int
    var size: CGFloat = 56
    var isActive = false
    var isBreathing = false

    private var clampedMood: Int {
        min(max(mood, 1), 5)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(isActive ? 0.72 : 0.42),
                            moodColor(clampedMood)
                        ],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: size * 0.82
                    )
                )

            Circle()
                .stroke(Color.white.opacity(isActive ? 0.72 : 0.34), lineWidth: max(1.2, size * 0.035))
                .padding(size * 0.08)

            moodScene
                .scaleEffect(size / 56)
                .offset(y: isActive && isBreathing ? -1.5 : 0)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(isActive && isBreathing ? 2.5 : -1.5))
        .shadow(color: moodColor(clampedMood).opacity(isActive ? 0.34 : 0.14), radius: isActive ? 8 : 3, x: 0, y: 4)
    }

    @ViewBuilder
    private var moodScene: some View {
        switch clampedMood {
        case 1:
            ZStack {
                Image(systemName: "cloud.drizzle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.74))
                    .offset(y: -2)

                ForEach(0..<3, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.48))
                        .frame(width: 3, height: 9)
                        .offset(x: CGFloat(index - 1) * 8, y: 18 + (isBreathing ? 2 : -1))
                }
            }
        case 2:
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.56))
                    .frame(width: 34, height: 23)
                    .rotationEffect(.degrees(-6))

                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.20))
                    .frame(width: 18, height: 3)
                    .offset(y: 2)
            }
        case 3:
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.58), lineWidth: 2)
                    .frame(width: 30, height: 30)

                Circle()
                    .fill(Color.white.opacity(0.50))
                    .frame(width: 9, height: 9)
                    .offset(x: isBreathing ? 8 : -8)
            }
        case 4:
            ZStack {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.48))
                    .frame(width: 5, height: 31)
                    .offset(y: 8)

                HStack(spacing: -2) {
                    LeafShape()
                        .fill(Color.white.opacity(0.64))
                        .frame(width: 18, height: 26)
                        .rotationEffect(.degrees(-35))

                    LeafShape()
                        .fill(Color.white.opacity(0.56))
                        .frame(width: 16, height: 24)
                        .rotationEffect(.degrees(35))
                }
                .offset(y: -3)
            }
        case 5:
            ZStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 31, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .rotationEffect(.degrees(isBreathing ? 12 : -8))

                Image(systemName: "sparkle")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .offset(x: 18, y: -18)
            }
        default:
            EmptyView()
        }
    }

    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1: return Color(red: 0.61, green: 0.72, blue: 0.78)
        case 2: return Color(red: 0.86, green: 0.74, blue: 0.57)
        case 3: return Color(red: 0.80, green: 0.78, blue: 0.70)
        case 4: return Color(red: 0.66, green: 0.80, blue: 0.65)
        default: return Color(red: 0.62, green: 0.82, blue: 0.89)
        }
    }
}

private struct MoodAura: View {
    let color: Color
    let isBreathing: Bool

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(0.18 - Double(index) * 0.035), lineWidth: 1.4)
                    .frame(width: 62 + CGFloat(index * 16), height: 62 + CGFloat(index * 16))
                    .scaleEffect(isBreathing ? 1.05 + CGFloat(index) * 0.025 : 0.95)
                    .opacity(isBreathing ? 0.58 : 0.30)
            }
        }
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.14))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.12))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY), control: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.12))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.14))
        return path
    }
}

struct MoodBadgeIcon: View {
    let mood: Int
    var size: CGFloat = 36

    var body: some View {
        MoodSceneIcon(mood: mood, size: size)
    }
}
