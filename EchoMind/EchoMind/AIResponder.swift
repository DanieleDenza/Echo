import Foundation
import AppKit
/* prova prova proviamo anche questa prova qui 
class AIResponder {
    private let apiKey = "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"

    func generateDailyReflection(from activityLog: [AppActivity], completion: @escaping (String?) -> Void) {
        let appSummary = summarize(activityLog: activityLog)
        let prompt = """
        Sei un assistente che analizza le abitudini di utilizzo del computer. In base a queste informazioni:
        \(appSummary)

        Scrivi una breve riflessione intelligente sulla giornata (massimo 2 frasi), in stile motivazionale ma anche critico.
        """

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion("Errore nella creazione della richiesta.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Errore rete: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("Nessun dato ricevuto.")
                return
            }

            print("🔵 Risposta JSON grezza:", String(data: data, encoding: .utf8) ?? "N/A")

            guard let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
                  let message = result.choices.first?.message.content else {
                completion("Errore nella decodifica della risposta dell'AI.")
                return
            }


            completion(message.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }


    private func summarize(activityLog: [AppActivity]) -> String {
        let grouped = Dictionary(grouping: activityLog, by: { $0.name })
        let summary = grouped.map { (app, entries) in
            let total = entries.reduce(0) { $0 + ($1.duration ?? 0) }
            return "\(app): \(Int(total / 60)) minuti"
        }
        return summary.joined(separator: ", ")
    }
}

// MARK: - Decodifica risposta
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }

    let choices: [Choice]
}
*/


class AIResponder {
    
    func generateDailyReflection(from activityLog: [AppActivity], completion: @escaping (String?) -> Void) {
        let appUsage = Dictionary(grouping: activityLog, by: { $0.name })
        let mostUsedApp = appUsage.max { $0.value.count < $1.value.count }?.key ?? "nessuna app"

        let fakeMessage = reflection(for: mostUsedApp)
        completion(fakeMessage)
    }

    private func reflection(for app: String) -> String {
        switch app {
        case "Xcode":
            return "Giornata intensa su Xcode: produttività tecnica ai massimi livelli. Continua così!"
        case "Excel":
            return "Hai passato molto tempo su Excel. Analisi, numeri e tabelle: giornata da stratega."
        case "Google Chrome":
            return "Molto tempo su Chrome. Stavi studiando, cercando ispirazione… o procrastinando un po’?"
        case "Safari":
            return "Safari ha dominato la scena. Navigazione libera o ricerca mirata?"
        case "Word":
            return "Hai scritto molto su Word: una giornata focalizzata sulla comunicazione o sulla creatività."
        case "Slack":
            return "Slack al centro della tua giornata. Collaborazione e messaggi senza sosta!"
        case "Teams":
            return "Ore passate su Teams: meeting, discussioni e lavoro di squadra a ritmo serrato."
        case "Edge":
            return "Tempo speso su Edge. Sei un tipo Microsoft? O semplicemente curioso?"
        default:
            return "Una giornata varia e interessante. Hai spaziato tra diverse attività con equilibrio."
        }
    }
}
