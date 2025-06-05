import SwiftUI
import AppKit
import UserNotifications
import Cocoa


@main
struct EchoMindApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("userMode") var userMode: String = ""
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
      
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    let popover = NSPopover()
    let aiResponder = AIResponder()

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ Icona barra inizializzata")
        // Icona nella barra
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "brain.head.profile", accessibilityDescription: "EchoMind")
            button.action = #selector(togglePopover(_:))
            
        }

        // Richiesta permessi notifica
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("❌ Errore permessi notifiche: \(error.localizedDescription)")
            } else {
                print("🔔 Permessi notifiche concessi: \(granted)")
            }
        }

        // Imposta contenuto iniziale popover
        updatePopoverContent()

        // Notifiche giornaliere e benessere
        scheduleDailyReflection(at: "17:40")
        scheduleHealthReminders()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            updatePopoverContent()
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.behavior = .transient
            }
        }
    }

    func updatePopoverContent() {
        let userMode = UserDefaults.standard.string(forKey: "userMode") ?? ""
        let tracker = AppTracker()

        if userMode.isEmpty {
            popover.contentViewController = NSHostingController(rootView: ModeSelectionView())
        } else {
            popover.contentViewController = NSHostingController(rootView: ContentView(tracker: tracker))
        }
    }

    func scheduleDailyReflection(at time: String) {
        let components = time.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return }

        let calendar = Calendar.current
        var date = calendar.date(bySettingHour: components[0], minute: components[1], second: 0, of: Date())!

        if date < Date() {
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        let timer = Timer(fireAt: date, interval: 86400, target: self, selector: #selector(triggerDailyReflection), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc func triggerDailyReflection() {
        guard let contentView = popover.contentViewController as? NSHostingController<ContentView> else { return }
        let tracker = contentView.rootView.tracker

        aiResponder.generateDailyReflection(from: tracker.activityLog) { message in
            DispatchQueue.main.async {
                self.showNotification(
                    title: "EchoMind – Riflessione del Giorno",
                    body: message ?? "Nessuna riflessione oggi."
                )
            }
        }
    }

    func scheduleHealthReminders() {
        let eyeBreakMessages = [
            "👀 Tempo di una pausa per gli occhi!",
            "Fissa qualcosa lontano per 20 secondi.",
            "Chiudi gli occhi e rilassati un attimo.",
            "Guarda fuori dalla finestra per un momento.",
            "Rilassa la vista: è importante!"
        ]

        let stretchMessages = [
            "🧍‍♂️ È il momento di alzarti e muoverti!",
            "Fai due passi, respira profondamente.",
            "Una camminata breve fa bene al corpo e alla mente.",
            "Hai bisogno di una pausa attiva!",
            "Ricarica il corpo con un piccolo movimento."
        ]

        Timer.scheduledTimer(withTimeInterval: 40 * 60, repeats: true) { _ in
            self.showNotification(title: "Pausa occhi", body: eyeBreakMessages.randomElement()!)
        }

        Timer.scheduledTimer(withTimeInterval: 2 * 60 * 60, repeats: true) { _ in
            self.showNotification(title: "Pausa movimento", body: stretchMessages.randomElement()!)
        }
    }

    func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // immediata
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Errore notifica: \(error.localizedDescription)")
            } else {
                print("✅ Notifica inviata: \(title)")
            }
        }
    }
}
