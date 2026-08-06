import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var sleep = SleepSummary.placeholder
    @State private var healthMessage: String?
    @State private var showsWelcome = false
    @State private var showsDiagnostics = false
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
                            title: "Dauer",
                            value: "\(displayedSleep.durationPoints)/50",
                            detail: displayedSleep.sleepDurationText,
                            color: .indigo
                        )
                        SleepMetricCard(
                            title: "Bettzeit",
                            value: "\(displayedSleep.bedtimePoints)/30",
                            detail: displayedSleep.bedtimeText,
                            color: .cyan
                        )
                        SleepMetricCard(
                            title: "Ruhe",
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
                healthMessage = "Health-Zugriff erlauben, um die letzte Nacht anzuzeigen."
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
    }
}

private struct MorningSceneChoice {
    let variant: Int
    let showsLady: Bool

    static func random() -> Self {
        Self(
            variant: Int.random(in: 0..<4),
            showsLady: Int.random(in: 0..<10) == 0
        )
    }

    func sceneAssetName(for state: BedState) -> String? {
        if showsLady, state == .refreshed {
            return "SceneLadyJump"
        }

        return switch state {
        case .exhausted:
            [nil, "SceneExhaustedSlide", "SceneExhaustedHidden", "SceneExhaustedEdgeSit"][variant]
        case .restless:
            [nil, "SceneRestlessPillow", "SceneRestlessTangle", "SceneRestlessPillowHug"][variant]
        case .okay:
            [nil, "SceneOkayStretch", "SceneOkayMakeBed", "SceneOkayWave"][variant]
        case .refreshed:
            [nil, "SceneRefreshedJump", "SceneRefreshedVictory", "SceneRefreshedCape"][variant]
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
                            title: "Aus Apple Health",
                            text: "Yawn Sleep liest deine Schlaf- und Wachphasen und berechnet daraus deinen persönlichen Yawn Score."
                        )
                        WelcomeCard(
                            icon: "function",
                            title: "So entsteht dein Score",
                            text: "Schlafdauer zählt bis zu 50 Punkte, die Regelmäßigkeit deiner Bettzeit bis zu 30 und ruhiger Schlaf mit wenigen Unterbrechungen bis zu 20 Punkte."
                        )
                        WelcomeCard(
                            icon: "info.circle.fill",
                            title: "Eine eigene Einschätzung",
                            text: "Der Yawn Score ist eine transparente Näherung aus deinen Health-Daten. Er ist nicht der Apple Sleep Score und kann davon abweichen."
                        )
                        WelcomeCard(
                            icon: "bed.double.fill",
                            title: "Ein Bett mit Gefühl",
                            text: "Bett und Lil’ Finder Guy zeigen sofort, wie erholsam deine Nacht war."
                        )
                        WelcomeCard(
                            icon: "lock.shield.fill",
                            title: "Bleibt auf deinem Gerät",
                            text: "Deine Gesundheitsdaten werden weder hochgeladen noch an Dritte weitergegeben."
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
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            LinearGradient(
                colors: [color.opacity(0.16), color.opacity(0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.22), lineWidth: 0.8)
        }
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
        """
        Yawn Sleep Diagnosebericht
        App: \(versionText)
        Erstellt: \(Date.now.formatted(date: .numeric, time: .shortened))

        Yawn Score: \(sleep.score)
        Dauer: \(sleep.durationPoints)/50 · \(sleep.sleepDurationText)
        Bettzeit: \(sleep.bedtimePoints)/30 · \(sleep.bedtimeText)
        Bettzeit-Abweichung: \(SleepSummary.durationText(abs(sleep.bedtimeConsistency)))
        Ruhe: \(sleep.interruptionPoints)/20 · \(sleep.interruptionText)

        Die Daten stammen lokal aus Apple Health. Es werden keine einzelnen
        HealthKit-Samples oder persönlichen Kennungen in diesen Bericht aufgenommen.
        """
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
