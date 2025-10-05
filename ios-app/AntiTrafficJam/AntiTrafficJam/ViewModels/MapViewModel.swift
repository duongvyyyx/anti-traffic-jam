import Foundation
import FirebaseFirestore
import Combine

class MapViewModel: ObservableObject {
    @Published var events: [TrafficEvent] = []
    private var listener: ListenerRegistration?

    func startListening(firebaseService: FirebaseService) {
        listener = firebaseService.listenToEvents { [weak self] events in
            DispatchQueue.main.async {
                self?.events = events
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
