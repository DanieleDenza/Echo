import SwiftUI

struct ModeSelectionView: View {
    @AppStorage("userMode") var userMode: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Seleziona la modalità")
                .font(.title2)
                .padding(.top, 30)

            HStack(spacing: 20) {
                Button(action: {
                    userMode = "Studente"
                }) {
                    Text("🧑‍🎓 Studente")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }

                Button(action: {
                    userMode = "Lavoratore"
                }) {
                    Text("👨‍💻 Lavoratore")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 30)
        }
        .frame(width: 320, height: 200)
        .padding()
    }
}
