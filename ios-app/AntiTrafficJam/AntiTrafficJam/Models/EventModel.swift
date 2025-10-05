import Foundation
import CoreLocation

enum EventType: String, Codable, CaseIterable {
    case trafficJam = "traffic_jam"
    case accident = "accident"
    case construction = "construction"
    case police = "police"

    var displayName: String {
        switch self {
        case .trafficJam: return "Traffic Jam"
        case .accident: return "Accident"
        case .construction: return "Construction"
        case .police: return "Police"
        }
    }

    var icon: String {
        switch self {
        case .trafficJam: return "car.fill"
        case .accident: return "exclamationmark.triangle.fill"
        case .construction: return "hammer.fill"
        case .police: return "shield.fill"
        }
    }

    var color: String {
        switch self {
        case .trafficJam: return "red"
        case .accident: return "orange"
        case .construction: return "yellow"
        case .police: return "blue"
        }
    }
}

struct TrafficEvent: Identifiable, Codable {
    var id: String
    var type: EventType
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var userId: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id, type, latitude, longitude, timestamp, userId
    }

    init(id: String = UUID().uuidString, type: EventType, latitude: Double, longitude: Double, timestamp: Date = Date(), userId: String) {
        self.id = id
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.userId = userId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(EventType.self, forKey: .type)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        userId = try container.decode(String.self, forKey: .userId)

        if let timestampMillis = try? container.decode(Int64.self, forKey: .timestamp) {
            timestamp = Date(timeIntervalSince1970: TimeInterval(timestampMillis) / 1000.0)
        } else {
            timestamp = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(Int64(timestamp.timeIntervalSince1970 * 1000), forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
    }
}
