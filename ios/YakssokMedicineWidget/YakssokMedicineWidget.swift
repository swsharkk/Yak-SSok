import SwiftUI
import WidgetKit

private let appGroupId = "group.com.example.yakssokFront"

struct MedicineEntry: TimelineEntry {
    let date: Date
    let medicineName: String
    let medicineTime: String
    let medicineDetail: String
    let isMissed: Bool
    let hasMedicine: Bool
}

struct MedicineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MedicineEntry {
        MedicineEntry(
            date: Date(),
            medicineName: "타이레놀",
            medicineTime: "오후 8:00",
            medicineDetail: "1알 · 식후",
            isMissed: false,
            hasMedicine: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MedicineEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MedicineEntry>) -> Void) {
        let entry = readEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func readEntry() -> MedicineEntry {
        let defaults = UserDefaults(suiteName: appGroupId)

        return MedicineEntry(
            date: Date(),
            medicineName: defaults?.string(forKey: "medicineName") ?? "오늘 약 확인",
            medicineTime: defaults?.string(forKey: "medicineTime") ?? "앱에서 일정 확인",
            medicineDetail: defaults?.string(forKey: "medicineDetail") ?? "복용 시간이 되면 알려드릴게요",
            isMissed: defaults?.bool(forKey: "isMissed") ?? false,
            hasMedicine: defaults?.object(forKey: "hasMedicine") as? Bool ?? false
        )
    }
}

struct YakssokMedicineWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MedicineEntry

    private var accentColor: Color {
        entry.isMissed ? Color(red: 0.88, green: 0.23, blue: 0.19) : Color(red: 0.04, green: 0.53, blue: 0.50)
    }

    var body: some View {
        widgetContent
            .widgetURL(URL(string: "yakssok://medicine/today"))
            .modifier(WidgetBackground())
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 10) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: entry.hasMedicine ? "pills.fill" : "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(accentColor, in: Circle())

                Text(entry.isMissed ? "놓친 약" : "다음 복용")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.medicineName)
                    .font(.system(size: family == .systemSmall ? 18 : 21, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(entry.medicineTime)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            if family != .systemSmall {
                Text(entry.medicineDetail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Image(systemName: entry.hasMedicine ? "hand.tap.fill" : "sparkles")
                    .font(.system(size: 11, weight: .bold))
                Text(entry.hasMedicine ? "복용하기" : "일정 보기")
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(accentColor, in: Capsule())
        }
        .padding(16)
    }
}

private struct WidgetBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(Color(.systemBackground), for: .widget)
        } else {
            content.background(Color(.systemBackground))
        }
    }
}

@main
struct YakssokMedicineWidget: Widget {
    let kind = "YakssokMedicineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MedicineProvider()) { entry in
            YakssokMedicineWidgetView(entry: entry)
        }
        .configurationDisplayName("약쏙 복용")
        .description("다음 복용 약과 시간을 바로 확인해요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
