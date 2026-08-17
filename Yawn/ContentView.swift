import SwiftUI
import UIKit
import CoreText

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var sleep = SleepSummary.placeholder
    @State private var healthMessage: String?
    @State private var showsWelcome = false
    @State private var showsDiagnostics = false
    @State private var showsLogs = false
    @State private var showsSchedule = false
    @State private var sceneChoice = MorningSceneChoice.random()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
#if DEBUG
    @State private var showsPoorPreview = false
#endif

    private var displayedSleep: SleepSummary {
#if DEBUG
        showsPoorPreview ? .poorPreview : sleep
#else
        sleep
#endif
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.965, green: 0.945, blue: 0.91)
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    Spacer()

                    ArchedYawnTitle()

                    MorningSceneView(
                        sleep: displayedSleep,
                        choice: sceneChoice
                    )
                    .contentTransition(.opacity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(displayedSleep.bedState.accessibilityLabel)

                    Text("\(displayedSleep.score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                        .contentTransition(.numericText())
                        .accessibilityLabel("Sleep Score \(displayedSleep.score)")
                        .offset(y: -8)

                    HStack(spacing: 10) {
                        SleepMetricCard(
                            title: String(localized: "Dauer"),
                            value: "\(displayedSleep.durationPoints)/50",
                            detail: displayedSleep.sleepDurationText,
                            color: .indigo
                        )
                        SleepMetricCard(
                            title: String(localized: "Bettzeit"),
                            value: "\(displayedSleep.bedtimePoints)/30",
                            detail: displayedSleep.bedtimeText,
                            color: .blue
                        )
                        SleepMetricCard(
                            title: String(localized: "Ruhe"),
                            value: "\(displayedSleep.interruptionPoints)/20",
                            detail: displayedSleep.interruptionText,
                            color: .orange
                        )
                    }
                    .offset(y: -8)

                    if let healthMessage {
                        Text(healthMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding(24)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        showsDiagnostics = true
                    } label: {
                        Image(systemName: "doc.text.magnifyingglass")
                    }
                    .accessibilityLabel("Diagnosebericht anzeigen")

                    Menu {
                        Button {
                            showsLogs = true
                        } label: {
                            Label("Schlafprotokolle", systemImage: "calendar")
                        }
                        Button {
                            showsSchedule = true
                        } label: {
                            Label("Aktueller Schlafrhythmus", systemImage: "bed.double")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Weitere Schlafdetails")

#if DEBUG
                    Button {
                        withAnimation(.easeInOut) {
                            showsPoorPreview.toggle()
                        }
                    } label: {
                        Image(systemName: showsPoorPreview ? "moon.zzz.fill" : "heart.text.square")
                    }
                    .accessibilityLabel(
                        showsPoorPreview
                            ? "Echte Health-Daten anzeigen"
                            : "Schlechten Testzustand anzeigen"
                    )
#endif
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsWelcome = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Willkommen und Hilfe")
                }
            }
        }
        .task {
            do {
                let summary = try await SleepHealthStore.shared.latestNight()
                sleep = summary
                WatchScoreSync.shared.send(score: summary.score)
                healthMessage = nil
            } catch {
                healthMessage = String(
                    localized: "Health-Zugriff erlauben, um die letzte Nacht anzuzeigen."
                )
            }
        }
        .onAppear {
            if !hasSeenWelcome {
                showsWelcome = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sceneChoice = .random()
            }
        }
        .sheet(isPresented: $showsWelcome) {
            WelcomeView {
                hasSeenWelcome = true
                showsWelcome = false
            }
        }
        .sheet(isPresented: $showsDiagnostics) {
            DiagnosticReportView(sleep: displayedSleep)
        }
        .sheet(isPresented: $showsLogs) {
            SleepLogView()
        }
        .sheet(isPresented: $showsSchedule) {
            SleepScheduleView()
        }
    }
}

private struct MorningSceneChoice {
    let variant: Int
    let showsLady: Bool
    let showsDuo: Bool

    static func random() -> Self {
        let specialVariant = Int.random(in: 0..<20)
        return Self(
            variant: Int.random(in: 0..<7),
            showsLady: specialVariant < 2,
            showsDuo: specialVariant == 2
        )
    }

    func sceneAssetName(for state: BedState) -> String? {
        if showsDuo {
            return switch state {
            case .exhausted: "SceneDuoExhausted"
            case .restless: "SceneDuoRestless"
            case .okay: "SceneDuoOkay"
            case .refreshed: "SceneDuoRefreshed"
            }
        }

        if showsLady {
            return switch state {
            case .exhausted: "SceneLadySleepy"
            case .restless: "SceneLadyYawning"
            case .okay: "SceneLadyMakeBed"
            case .refreshed: "SceneLadyJump"
            }
        }

        return switch state {
        case .exhausted:
            [
                nil,
                "SceneExhaustedSlide",
                "SceneExhaustedHidden",
                "SceneExhaustedEdgeSit",
                "SceneExhaustedFaceDown",
                "SceneExhaustedCocoon",
                "SceneExhaustedSlumped"
            ][variant]
        case .restless:
            [
                nil,
                "SceneRestlessPillow",
                "SceneRestlessTangle",
                "SceneRestlessPillowHug",
                "SceneRestlessTangledLeg",
                "SceneRestlessPillowStack",
                "SceneRestlessEyeRub"
            ][variant]
        case .okay:
            [
                nil,
                "SceneOkayStretch",
                "SceneOkayMakeBed",
                "SceneOkayWave",
                "SceneOkayShoulderStretch",
                "SceneOkayFoldBlanket",
                "SceneOkayThumbsUp"
            ][variant]
        case .refreshed:
            [
                nil,
                "SceneRefreshedJump",
                "SceneRefreshedVictory",
                "SceneRefreshedCape",
                "SceneRefreshedBalance",
                "SceneRefreshedPresentBed",
                "SceneRefreshedDance"
            ][variant]
        }
    }
}

private struct ArchedYawnTitle: View {
    private let letters = Array("Yawn Score")

    var body: some View {
        GeometryReader { geometry in
            let count = max(letters.count - 1, 1)
            let usableWidth = min(geometry.size.width, 240)
            let startX = (geometry.size.width - usableWidth) / 2

            ZStack {
                ForEach(letters.indices, id: \.self) { index in
                    let progress = Double(index) / Double(count)
                    let curvePosition = progress * 2 - 1

                    Text(String(letters[index]))
                        .font(.system(size: 35, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.indigo, .blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(curvePosition * 7))
                        .position(
                            x: startX + usableWidth * progress,
                            y: 19 + abs(curvePosition) * 10
                        )
                }
            }
        }
        .frame(height: 42)
        .padding(.bottom, -12)
        .shadow(color: .blue.opacity(0.14), radius: 4, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Yawn Score")
    }
}

private struct MorningSceneView: View {
    let sleep: SleepSummary
    let choice: MorningSceneChoice

    var body: some View {
        if let sceneAssetName = choice.sceneAssetName(for: sleep.bedState) {
            Image(sceneAssetName)
                .resizable()
                .scaledToFit()
        } else {
            ZStack(alignment: .bottomLeading) {
                Image(sleep.bedAssetName)
                    .resizable()
                    .scaledToFit()

                Image(sleep.bedState.characterAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .offset(x: -2, y: 28)
            }
        }
    }
}

private struct WelcomeView: View {
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.97, blue: 1),
                    Color(red: 0.88, green: 0.93, blue: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Image("GuyRefreshed")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 190)
                        .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("Willkommen bei Yawn Sleep")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text("Deine Nacht – auf einen Blick.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 12) {
                        WelcomeCard(
                            icon: "heart.text.square.fill",
                            title: String(localized: "Aus Apple Health"),
                            text: String(localized: "Yawn Sleep liest deine Schlaf- und Wachphasen und berechnet daraus deinen persönlichen Yawn Score.")
                        )
                        WelcomeCard(
                            icon: "function",
                            title: String(localized: "So entsteht dein Score"),
                            text: String(localized: "Schlafdauer zählt bis zu 50 Punkte, die Regelmäßigkeit deiner Bettzeit bis zu 30 und ruhiger Schlaf mit wenigen Unterbrechungen bis zu 20 Punkte.")
                        )
                        WelcomeCard(
                            icon: "info.circle.fill",
                            title: String(localized: "Eine eigene Einschätzung"),
                            text: String(localized: "Der Yawn Score ist eine transparente Näherung aus deinen Health-Daten. Er ist nicht der Apple Sleep Score und kann davon abweichen.")
                        )
                        WelcomeCard(
                            icon: "bed.double.fill",
                            title: String(localized: "Ein Bett mit Gefühl"),
                            text: String(localized: "Bett und Lil’ Finder Guy zeigen sofort, wie erholsam deine Nacht war.")
                        )
                        WelcomeCard(
                            icon: "lock.shield.fill",
                            title: String(localized: "Bleibt auf deinem Gerät"),
                            text: String(localized: "Deine Gesundheitsdaten werden weder hochgeladen noch an Dritte weitergegeben.")
                        )
                    }

                    Button(action: dismiss) {
                        Text("Los geht’s")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)

                    Text("Über das ? kannst du diesen Bildschirm jederzeit wieder öffnen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Link(
                        "Datenschutzerklärung",
                        destination: URL(string: "https://lutzrfrank.github.io/Yawn/privacy.html")!
                    )
                    .font(.footnote.weight(.semibold))
                }
                .padding(24)
            }
        }
    }
}

private struct WelcomeCard: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.7), lineWidth: 0.8)
        }
    }
}

private struct SleepMetricCard: View {
    let title: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
            }

            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.primary.opacity(0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            LinearGradient(
                colors: [color.opacity(0.32), color.opacity(0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.5), lineWidth: 1)
        }
    }
}

private enum LogPeriod: String, CaseIterable, Identifiable {
    case week, month, year
    var id: Self { self }
    var days: Int { switch self { case .week: 7; case .month: 31; case .year: 366 } }
    var title: String {
        switch self {
        case .week: String(localized: "Woche")
        case .month: String(localized: "Monat")
        case .year: String(localized: "Jahr")
        }
    }
}

private struct SleepLogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var period: LogPeriod = .week
    @State private var history: [SleepSummary] = []
    @State private var errorMessage: String?

    private var entries: [SleepSummary] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -period.days, to: .now) ?? .distantPast
        return Array(history.filter { $0.bedtime >= cutoff }.reversed())
    }

    private var reportText: String {
        let rows = entries.map {
            "\($0.bedtime.formatted(date: .abbreviated, time: .omitted))\t\($0.score)\t\($0.sleepDurationText)\t\($0.bedtimeText)\t\($0.interruptionText)"
        }
        let average = entries.isEmpty ? 0 : entries.reduce(0) { $0 + $1.score } / entries.count
        return ([String(localized: "Yawn Schlafprotokoll") + " — \(period.title)",
                 String(localized: "Durchschnittlicher Score") + ": \(average)", "",
                 String(localized: "Datum\tScore\tDauer\tBettzeit\tRuhe")] + rows).joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Zeitraum", selection: $period) {
                    ForEach(LogPeriod.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)

                if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "heart.slash")
                } else if history.isEmpty {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        Text(reportText)
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        ShareLink(item: reportText) {
                            Label("Text teilen", systemImage: "doc.plaintext")
                        }
                        .buttonStyle(.bordered)

                        if let pdfURL = SleepReportFile.pdf(text: reportText, name: period.title) {
                            ShareLink(item: pdfURL) {
                                Label("PDF teilen", systemImage: "doc.richtext")
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                UIPrintInteractionController.shared.printingItem = pdfURL
                                UIPrintInteractionController.shared.present(animated: true)
                            } label: {
                                Image(systemName: "printer")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Protokoll drucken")
                        }
                    }
                }
            }
            .padding(20)
            .background(Color(red: 0.965, green: 0.945, blue: 0.91))
            .navigationTitle("Schlafprotokolle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } } }
        }
        .task {
            do { history = try await SleepHealthStore.shared.sleepHistory() }
            catch { errorMessage = String(localized: "Schlafdaten konnten nicht geladen werden.") }
        }
    }
}

private struct SleepScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history: [SleepSummary] = []

    private var recent: ArraySlice<SleepSummary> { history.suffix(14) }
    private func averageTime(_ dates: [Date]) -> String {
        guard !dates.isEmpty else { return "–" }
        let calendar = Calendar.current
        let minutes = dates.map { Double(calendar.component(.hour, from: $0) * 60 + calendar.component(.minute, from: $0)) }
        let angles = minutes.map { $0 / 1440 * 2 * Double.pi }
        let angle = atan2(angles.reduce(0) { $0 + sin($1) }, angles.reduce(0) { $0 + cos($1) })
        let normalized = angle < 0 ? angle + 2 * .pi : angle
        let total = Int((normalized / (2 * .pi) * 1440).rounded()) % 1440
        let date = calendar.date(bySettingHour: total / 60, minute: total % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Aus den letzten 14 Nächten") {
                    LabeledContent("Übliche Bettzeit", value: averageTime(recent.map(\.bedtime)))
                    LabeledContent("Übliche Aufstehzeit", value: averageTime(recent.map(\.wakeTime)))
                    LabeledContent("Erfasste Nächte", value: "\(recent.count)")
                }
                Section {
                    Text("Apple stellt die in Health konfigurierte Schlafplan-Einstellung Apps nicht zur Verfügung. Diese Zeiten sind deshalb aus deinen zuletzt aufgezeichneten Schlafdaten berechnet.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Aktueller Schlafrhythmus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } } }
        }
        .task { history = (try? await SleepHealthStore.shared.sleepHistory(days: 30)) ?? [] }
    }
}

private enum SleepReportFile {
    static func pdf(text: String, name: String) -> URL? {
        let safeName = name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Yawn-\(safeName).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        do {
            try renderer.writePDF(to: url) { context in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
                let attributed = NSAttributedString(string: text, attributes: attributes)
                var offset = 0
                while offset < attributed.length {
                    context.beginPage()
                    let frame = CGRect(x: 42, y: 42, width: 511, height: 758)
                    let setter = CTFramesetterCreateWithAttributedString(attributed)
                    let path = CGPath(rect: frame, transform: nil)
                    let range = CFRange(location: offset, length: 0)
                    let pdfFrame = CTFramesetterCreateFrame(setter, range, path, nil)
                    CTFrameDraw(pdfFrame, context.cgContext)
                    let visible = CTFrameGetVisibleStringRange(pdfFrame)
                    guard visible.length > 0 else { break }
                    offset += visible.length
                }
            }
            return url
        } catch { return nil }
    }
}

private struct DiagnosticReportView: View {
    @Environment(\.dismiss) private var dismiss
    let sleep: SleepSummary

    private var versionText: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "–"
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "–"
        return "\(version) (\(build))"
    }

    private var reportText: String {
        let created = Date.now.formatted(date: .numeric, time: .shortened)
        let deviation = SleepSummary.durationText(abs(sleep.bedtimeConsistency))
        return String(
            format: NSLocalizedString("diagnostic.report", comment: "Shared diagnostic report"),
            versionText,
            created,
            sleep.score,
            sleep.durationPoints,
            sleep.sleepDurationText,
            sleep.bedtimePoints,
            sleep.bedtimeText,
            deviation,
            sleep.interruptionPoints,
            sleep.interruptionText
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Label("Lokaler Diagnosebericht", systemImage: "heart.text.square")
                        .font(.title2.bold())
                        .foregroundStyle(.indigo)

                    Text(reportText)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))

                    ShareLink(item: reportText) {
                        Label("Bericht teilen", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)

                    Text("Der Bericht verlässt dein Gerät nur, wenn du ihn ausdrücklich teilst.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .background(Color(red: 0.965, green: 0.945, blue: 0.91))
            .navigationTitle("Diagnose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
