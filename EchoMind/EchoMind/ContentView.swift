import SwiftUI

struct ContentView: View {
    @ObservedObject var tracker: AppTracker
    @State private var showDetails = false // 🔘 Stato toggle per lista

    var appDurations: [(key: String, value: TimeInterval)] {
        let durations = Dictionary(
            grouping: tracker.activityLog.compactMap { $0.duration != nil ? $0 : nil },
            by: { $0.name }
        ).mapValues { $0.reduce(0) { $0 + ($1.duration ?? 0) } }

        return durations.sorted { $0.value > $1.value }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("🧠 EchoMind")
                    .font(.title2.bold())

                Text("💭 \(tracker.generateThoughtOfTheDay())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Timeline grafica
            if !appDurations.isEmpty {
                Text("⏱ Tempo speso per app")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)

                ForEach(appDurations.prefix(5), id: \.key) { app, duration in
                    VStack(alignment: .leading) {
                        Text(app)
                            .font(.caption)
                        GeometryReader { geo in
                            Rectangle()
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: geo.size.width * CGFloat(duration / (appDurations.first?.value ?? 1.0)), height: 8)
                                .cornerRadius(4)
                        }
                        .frame(height: 8)
                        Text("\(Int(duration) / 60) min")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }

            Divider()

            // 🔘 Bottone per mostrare/nascondere lista
            Button(action: {
                withAnimation {
                    showDetails.toggle()
                }
            }) {
                Text(showDetails ? "🔽 Nascondi attività" : "📋 Mostra attività dettagliate")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            // ✅ Lista visibile solo se attivata
            if showDetails {
                if tracker.activityLog.isEmpty {
                    Text("Nessuna attività rilevata.")
                        .foregroundColor(.gray)
                        .frame(minHeight: 80)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(Array(tracker.activityLog.reversed())) { activity in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(activity.name)
                                            .fontWeight(.semibold)
                                        Text(activity.timestamp.formatted(date: .omitted, time: .standard))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 5)
                    }
                    .frame(minHeight: 150, maxHeight: 250)
                }
            }
        }
        .padding(16)
        .frame(minWidth: 320, idealWidth: 340)
    }
}
