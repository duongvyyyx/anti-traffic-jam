import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let apiBaseURL = "http://localhost:8080"
    private var userId: String = ""

    init() {
        signInAnonymously()
    }

    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            if let error = error {
                print("Anonymous sign-in error: \(error.localizedDescription)")
                self?.userId = UUID().uuidString
            } else if let user = authResult?.user {
                self?.userId = user.uid
            }
        }
    }

    func reportEvent(type: EventType, latitude: Double, longitude: Double) async throws {
        let event = TrafficEvent(
            type: type,
            latitude: latitude,
            longitude: longitude,
            userId: userId
        )

        guard let url = URL(string: "\(apiBaseURL)/report") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(event)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func listenToEvents(completion: @escaping ([TrafficEvent]) -> Void) -> ListenerRegistration {
        let listener = db.collection("events")
            .order(by: "timestamp", descending: true)
            .limit(to: 500)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching events: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }

                let events = documents.compactMap { doc -> TrafficEvent? in
                    try? doc.data(as: TrafficEvent.self)
                }

                let filteredEvents = events.filter { event in
                    let ageInHours = Date().timeIntervalSince(event.timestamp) / 3600
                    return ageInHours < 2
                }

                completion(filteredEvents)
            }

        return listener
    }

    func fetchEvents(latitude: Double, longitude: Double, radiusKm: Double) async throws -> [TrafficEvent] {
        guard let url = URL(string: "\(apiBaseURL)/events?lat=\(latitude)&lon=\(longitude)&radius=\(radiusKm)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let events = try decoder.decode([TrafficEvent].self, from: data)
        return events
    }
}
