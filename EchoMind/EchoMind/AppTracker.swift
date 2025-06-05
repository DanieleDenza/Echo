import Foundation
import AppKit

public class AppTracker: ObservableObject {
    @Published var activityLog: [AppActivity] = []
    
    init() {
        startTracking()
    }
    
    private var lastActivity: AppActivity?

    
    func startTracking() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    
    @objc func appDidActivate(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let appName = app.localizedName else { return }

        let now = Date()

        // Se esiste un'attività precedente, calcoliamo durata
        if var previous = lastActivity {
            previous.duration = now.timeIntervalSince(previous.timestamp)
            activityLog.append(previous)
        }

        let newActivity = AppActivity(
            name: appName,
            timestamp: now
        )

        lastActivity = newActivity

        print("[LOG] App attiva: \(appName)")
        saveLogToFile()
    }

    
    func saveLogToFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(activityLog)
            let fileURL = getLogFileURL()
            
            try data.write(to: fileURL)
            print("✅ Log salvato su file: \(fileURL.path)")
        } catch {
            print("❌ Errore nel salvataggio: \(error.localizedDescription)")
        }
    }
    
    private func getLogFileURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let filename = "diario-\(dateString).json"
        let tempURL = FileManager.default.temporaryDirectory
        return tempURL.appendingPathComponent(filename)
    }
    
 

    
    func generateThoughtOfTheDay() -> String {
        // Conta le occorrenze delle app usate
        let appNames = activityLog.map { $0.name }
        let frequency = Dictionary(grouping: appNames, by: { $0 })
            .mapValues { $0.count }
        
        // Ordina per frequenza
        let sorted = frequency.sorted { $0.value > $1.value }
        
        // App usata più spesso
        guard let mostUsedApp = sorted.first else {
            return "Oggi non hai usato molte app, giornata tranquilla?"
        }
        
        // Semplici frasi personalizzate
        switch mostUsedApp.key {
        case "Xcode":
            return "Hai trascorso molto tempo su Xcode: giornata produttiva e tecnica."
        case "Safari":
            return "Oggi ti sei mosso su Safari: esplorazione, ricerca o relax?"
        case "Mail":
            return "Molto tempo su Mail: giornata intensa di comunicazioni."
        case "Notes":
            return "Giornata riflessiva? Hai usato molto Notes."
        default:
            return "Hai lavorato molto con \(mostUsedApp.key): giornata concentrata e attiva."
        }
    }
    
    func exportWeeklySummaryCSV() {
        let fileName = "weekly-summary-\(Date().formatted(.dateTime.day().month().year())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csv = "App,Durata (minuti)\n"
        let summary = Dictionary(grouping: activityLog, by: { $0.name })
            .mapValues { $0.reduce(0) { $0 + ($1.duration ?? 0) } }

        for (app, duration) in summary.sorted(by: { $0.value > $1.value }) {
            csv += "\(app),\(Int(duration / 60))\n"
        }

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            print("📄 CSV esportato in: \(url.path)")
        } catch {
            print("❌ Errore nell'esportazione CSV: \(error.localizedDescription)")
        }
    }



}

import Foundation
import AppKit

struct AppActivity: Identifiable, Codable {
    var id = UUID()
    let name: String
    let timestamp: Date
    var duration: TimeInterval? = nil
}


