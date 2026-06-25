import SwiftUI

struct SettingsScreenView: View {
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue
    @AppStorage(AppStorageKeys.selectedAppearance) private var selectedAppearanceRaw: String = AppAppearanceMode.system.rawValue
    @AppStorage(AppStorageKeys.reminderTimesCSV) private var reminderTimesCSV: String = "08:00,20:00"
    @AppStorage(AppStorageKeys.simulateNetworkFailure) private var simulateNetworkFailure = false

    @State private var reminderTimes: [Date] = []
    @State private var reminderStatusMessage: String?

    private let notificationScheduler = NotificationScheduler()

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localized(vi: "Ngôn ngữ", en: "Language")) {
                    Picker("", selection: $selectedLanguageRaw) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(localized(vi: "Giao diện", en: "Appearance")) {
                    Picker("", selection: $selectedAppearanceRaw) {
                        ForEach(AppAppearanceMode.allCases) { mode in
                            Text(mode.displayName(language: selectedLanguage)).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(localized(vi: "Nhắc nhở mỗi ngày", en: "Daily reminders")) {
                    if reminderTimes.isEmpty {
                        Text(localized(vi: "Chưa có khung giờ.", en: "No reminder times yet."))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(reminderTimes.indices, id: \.self) { index in
                        HStack {
                            DatePicker(
                                "",
                                selection: bindingForReminder(at: index),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()

                            Spacer()

                            Button(role: .destructive) {
                                reminderTimes.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }

                    Button {
                        reminderTimes.append(ReminderTimeCodec.suggestedNewTime(from: reminderTimes))
                    } label: {
                        Label(localized(vi: "Thêm khung giờ", en: "Add reminder"), systemImage: "plus.circle")
                    }

                    Button {
                        Task {
                            await saveReminderSchedule()
                        }
                    } label: {
                        Text(localized(vi: "Lưu lịch nhắc", en: "Save schedule"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    if let reminderStatusMessage {
                        Text(reminderStatusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(localized(vi: "Debug", en: "Debug")) {
                    Toggle(
                        localized(vi: "Giả lập mất mạng (test cache)", en: "Simulate offline mode (cache test)"),
                        isOn: $simulateNetworkFailure
                    )

                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        Text(localized(vi: "Xem lại onboarding", en: "Replay onboarding"))
                    }
                }
            }
            .navigationTitle(localized(vi: "Cài đặt", en: "Settings"))
            .scrollContentBackground(.hidden)
            .background(HealingTheme.screenBackground(for: colorScheme).ignoresSafeArea())
            .tint(HealingTheme.primaryAccent(for: colorScheme))
            .onAppear {
                reminderTimes = ReminderTimeCodec.decode(csv: reminderTimesCSV)
            }
        }
    }

    private func bindingForReminder(at index: Int) -> Binding<Date> {
        Binding(
            get: { reminderTimes[index] },
            set: { reminderTimes[index] = $0 }
        )
    }

    private func saveReminderSchedule() async {
        let normalized = reminderTimes.sorted()
        reminderTimes = normalized
        reminderTimesCSV = ReminderTimeCodec.encode(times: normalized)

        let granted = await notificationScheduler.requestPermission()
        guard granted else {
            reminderStatusMessage = localized(
                vi: "Bạn chưa cấp quyền thông báo cho app.",
                en: "Notification permission is not granted for this app."
            )
            return
        }

        do {
            try await notificationScheduler.scheduleDailyReminders(times: normalized, language: selectedLanguage)
            reminderStatusMessage = localized(vi: "Đã lưu lịch nhắc thành công.", en: "Reminder schedule saved successfully.")
        } catch {
            reminderStatusMessage = error.localizedDescription
        }
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }
}
