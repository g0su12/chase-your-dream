import SwiftUI

enum HealingTheme {
    static func screenBackground(for colorScheme: ColorScheme) -> LinearGradient {
        switch colorScheme {
        case .dark:
            return LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.11, blue: 0.14),
                    Color(red: 0.06, green: 0.18, blue: 0.21),
                    Color(red: 0.10, green: 0.24, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.92, blue: 0.86),
                    Color(red: 0.91, green: 0.95, blue: 0.90),
                    Color(red: 0.86, green: 0.93, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    static func primaryAccent(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.52, green: 0.82, blue: 0.74)
        default:
            return Color(red: 0.48, green: 0.62, blue: 0.51)
        }
    }

    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.10, green: 0.19, blue: 0.23).opacity(0.92)
        default:
            return Color(red: 0.98, green: 0.98, blue: 0.97).opacity(0.88)
        }
    }

    static func cardStroke(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.52, green: 0.82, blue: 0.74).opacity(0.24)
        default:
            return Color(red: 0.73, green: 0.79, blue: 0.75).opacity(0.42)
        }
    }

    static func quoteTint(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.97, green: 0.77, blue: 0.54).opacity(0.20)
        default:
            return Color(red: 0.97, green: 0.79, blue: 0.66).opacity(0.28)
        }
    }

    static func storyTint(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.46, green: 0.71, blue: 0.88).opacity(0.18)
        default:
            return Color(red: 0.73, green: 0.86, blue: 0.95).opacity(0.25)
        }
    }

    static func successTint(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.45, green: 0.85, blue: 0.67).opacity(0.16)
        default:
            return Color(red: 0.68, green: 0.80, blue: 0.65).opacity(0.24)
        }
    }

    static func suggestionTint(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.95, green: 0.70, blue: 0.45).opacity(0.18)
        default:
            return Color(red: 0.97, green: 0.77, blue: 0.62).opacity(0.26)
        }
    }

    static func panelBackground(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color.white.opacity(0.06)
        default:
            return Color.white.opacity(0.58)
        }
    }
}

struct HealingCardStyle: ViewModifier {
    let colorScheme: ColorScheme
    var tint: Color?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill((tint ?? HealingTheme.cardBackground(for: colorScheme)).opacity(0.95))

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.10))
                        .blur(radius: 18)
                        .opacity(0.35)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 1)
                )
            )
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.24)
                    : Color(red: 0.43, green: 0.50, blue: 0.44).opacity(0.16),
                radius: colorScheme == .dark ? 12 : 10,
                x: 0,
                y: 6
            )
    }
}

extension View {
    func healingCard(colorScheme: ColorScheme, tint: Color? = nil) -> some View {
        modifier(HealingCardStyle(colorScheme: colorScheme, tint: tint))
    }
}
