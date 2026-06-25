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
                MoodBadgeIcon(mood: mood, size: size)
            }
        }
    }
}

struct MoodSliderSelector: View {
    @Binding var moodLevel: Int
    var minValue: Int = 1
    var maxValue: Int = 5

    var body: some View {
        GeometryReader { proxy in
            let values = Array(minValue...maxValue)
            let horizontalInset: CGFloat = 2
            let contentWidth = max(proxy.size.width - (horizontalInset * 2), 1)
            let stepWidth = contentWidth / CGFloat(values.count)
            let selectedIndex = CGFloat(max(min(moodLevel - minValue, values.count - 1), 0))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.08))

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.58))
                    .frame(width: max(stepWidth, 1))
                    .offset(x: horizontalInset + selectedIndex * stepWidth)

                HStack(spacing: 0) {
                    ForEach(values, id: \.self) { value in
                        let isSelected = value == moodLevel
                        MoodBadgeIcon(mood: value, size: 30)
                            .opacity(isSelected ? 1 : 0.78)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.84)) {
                                    moodLevel = value
                                }
                            }
                    }
                }
                .padding(.horizontal, horizontalInset)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let relativeX = min(max(drag.location.x - horizontalInset, 0), contentWidth - 0.001)
                        let rawIndex = Int(relativeX / max(stepWidth, 1))
                        let clampedIndex = min(max(rawIndex, 0), values.count - 1)
                        let newValue = values[clampedIndex]
                        if newValue != moodLevel {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.86)) {
                                moodLevel = newValue
                            }
                        }
                    }
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.84), value: moodLevel)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
    }
}

struct MoodBadgeIcon: View {
    let mood: Int
    var size: CGFloat = 36

    private var clampedMood: Int {
        min(max(mood, 1), 5)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.32),
                            moodColor(clampedMood)
                        ],
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: size * 0.7
                    )
                )

            Circle()
                .stroke(Color.black.opacity(0.10), lineWidth: max(0.8, size * 0.026))

            MoodFaceGlyph(mood: clampedMood)
                .scaleEffect(size / 28)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
    }

    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1: return Color(red: 0.66, green: 0.75, blue: 0.80)
        case 2: return Color(red: 0.87, green: 0.77, blue: 0.62)
        case 3: return Color(red: 0.82, green: 0.81, blue: 0.76)
        case 4: return Color(red: 0.71, green: 0.81, blue: 0.71)
        default: return Color(red: 0.66, green: 0.80, blue: 0.85)
        }
    }
}

private struct MoodFaceGlyph: View {
    let mood: Int

    var body: some View {
        ZStack {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 2.1, height: 2.1)
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 2.1, height: 2.1)
            }
            .offset(y: -3)

            MoodMouthShape(curveDepth: curveDepth(for: mood))
                .stroke(Color.black.opacity(0.42), lineWidth: 1.2)
                .frame(width: 8, height: 4)
                .offset(y: 3)
        }
        .frame(width: 12, height: 12)
    }

    private func curveDepth(for mood: Int) -> CGFloat {
        switch mood {
        case 1: return 2.6
        case 2: return 1.2
        case 3: return 0
        case 4: return -1.2
        default: return -2.6
        }
    }
}

private struct MoodMouthShape: Shape {
    let curveDepth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let y = rect.midY
        path.move(to: CGPoint(x: rect.minX + 0.5, y: y))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 0.5, y: y),
            control: CGPoint(x: rect.midX, y: y + curveDepth)
        )

        return path
    }
}
