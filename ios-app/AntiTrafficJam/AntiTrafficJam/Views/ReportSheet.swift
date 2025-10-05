import SwiftUI
import CoreLocation

struct ReportSheet: View {
    let userLocation: CLLocationCoordinate2D?
    let firebaseService: FirebaseService
    @Binding var isPresented: Bool
    @State private var isSubmitting = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Report Event")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 24)
                    .padding(.bottom, 32)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(EventType.allCases, id: \.self) { eventType in
                        Button(action: {
                            submitReport(type: eventType)
                        }) {
                            VStack(spacing: 16) {
                                Image(systemName: eventType.icon)
                                    .font(.system(size: 44))
                                    .foregroundColor(colorForType(eventType))

                                Text(eventType.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(colorForType(eventType).opacity(0.3), lineWidth: 2)
                            )
                        }
                        .disabled(isSubmitting)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                if isSubmitting {
                    ProgressView()
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .disabled(isSubmitting)
                }
            }
        }
    }

    private func colorForType(_ type: EventType) -> Color {
        switch type.color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "blue": return .blue
        default: return .gray
        }
    }

    private func submitReport(type: EventType) {
        guard let location = userLocation else {
            return
        }

        isSubmitting = true

        Task {
            do {
                try await firebaseService.reportEvent(
                    type: type,
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                await MainActor.run {
                    isSubmitting = false
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                }
                print("Error submitting report: \(error)")
            }
        }
    }
}
