# Anti-Traffic Jam

A native iOS application for reporting and viewing real-time traffic events (traffic jams, accidents, construction, police checkpoints) with a Go backend and Firebase integration.

## Architecture

- **iOS App**: Native Swift + SwiftUI with MapKit
- **Backend**: Go REST API
- **Database**: Firebase Firestore
- **Authentication**: Firebase Anonymous Auth

## Project Structure

```
.
├── ios-app/                      # iOS application
│   └── AntiTrafficJam/
│       ├── AntiTrafficJam/
│       │   ├── Views/           # SwiftUI views
│       │   ├── Models/          # Data models
│       │   ├── Services/        # Location & Firebase services
│       │   ├── ViewModels/      # View models
│       │   └── Assets.xcassets/ # App assets
│       └── AntiTrafficJam.xcodeproj/
├── backend/                      # Go backend server
│   ├── cmd/server/              # Main server entry point
│   ├── internal/
│   │   ├── handlers/            # HTTP handlers
│   │   ├── models/              # Data models
│   │   └── firebase/            # Firebase client
│   └── config/                  # Configuration files
└── firebase/                     # Firebase configuration
    ├── firestore.rules          # Firestore security rules
    └── firestore.indexes.json   # Firestore indexes
```

## Setup Instructions

### Prerequisites

- Xcode 15.0+
- Go 1.21+
- Firebase project
- iOS device or simulator (iOS 16.0+)

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable Firebase Authentication:
   - Go to Authentication → Sign-in method
   - Enable "Anonymous" authentication

3. Create a Firestore database:
   - Go to Firestore Database
   - Create database in production mode
   - Choose a location

4. Download iOS configuration:
   - Go to Project Settings → Your apps
   - Add an iOS app with bundle ID: `com.antitrafficjam.app`
   - Download `GoogleService-Info.plist`
   - Replace `ios-app/AntiTrafficJam/AntiTrafficJam/GoogleService-Info.plist` with the downloaded file

5. Generate service account credentials for backend:
   - Go to Project Settings → Service accounts
   - Click "Generate new private key"
   - Save as `backend/config/firebase-credentials.json`

6. Deploy Firestore rules and indexes:
   ```bash
   cd firebase
   firebase deploy --only firestore
   ```

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   make deps
   ```

3. Create `.env` file (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

4. Run the server:
   ```bash
   make run
   ```

   The server will start on `http://localhost:8080`

### iOS App Setup

1. Open the Xcode project:
   ```bash
   cd ios-app/AntiTrafficJam
   open AntiTrafficJam.xcodeproj
   ```

2. Install Firebase iOS SDK:
   - In Xcode, go to File → Add Package Dependencies
   - Enter: `https://github.com/firebase/firebase-ios-sdk.git`
   - Select version 10.20.0 or higher
   - Add the following packages:
     - FirebaseAuth
     - FirebaseFirestore

3. Configure backend URL:
   - Open `Services/FirebaseService.swift`
   - Update `apiBaseURL` if your backend is not running on localhost:8080

4. Build and run:
   - Select a simulator or connected device
   - Press Cmd+R to build and run

## API Endpoints

### POST /report
Submit a new traffic event.

**Request Body:**
```json
{
  "id": "uuid",
  "type": "traffic_jam|accident|construction|police",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "timestamp": 1234567890000,
  "userId": "user-id"
}
```

**Response:**
```json
{
  "status": "success",
  "id": "event-id"
}
```

### GET /events
Fetch events within a radius.

**Query Parameters:**
- `lat` (required): Latitude
- `lon` (required): Longitude
- `radius` (optional): Radius in km (default: 10)

**Response:**
```json
[
  {
    "id": "event-id",
    "type": "traffic_jam",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "timestamp": 1234567890000,
    "userId": "user-id"
  }
]
```

### GET /health
Health check endpoint.

**Response:** `OK` (200)

## Features

### Implemented (Phase 1 MVP)

- ✅ Full-screen map with Apple MapKit
- ✅ Real-time event markers (traffic jam, accident, construction, police)
- ✅ Report events via floating action button
- ✅ Anonymous authentication
- ✅ Location tracking
- ✅ Dark mode support
- ✅ Event clustering
- ✅ Go REST API with validation
- ✅ Firebase Firestore integration
- ✅ Real-time event sync
- ✅ Events auto-expire after 2 hours

### Planned (Future Phases)

- 🔲 Push notifications
- 🔲 AI-powered routing suggestions
- 🔲 Event upvoting/verification
- 🔲 User profiles
- 🔲 Historical traffic patterns
- 🔲 Social features

## Event Types

| Type | Icon | Color | Description |
|------|------|-------|-------------|
| Traffic Jam | 🚗 | Red | Heavy traffic congestion |
| Accident | ⚠️ | Orange | Vehicle accident |
| Construction | 🔨 | Yellow | Road construction |
| Police | 🛡️ | Blue | Police checkpoint |

## Development

### Running Tests

Backend:
```bash
cd backend
make test
```

### Building for Production

Backend:
```bash
cd backend
make build
```

iOS:
1. Open Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Follow App Store submission guidelines

## Security

- Anonymous authentication prevents spam
- Firestore security rules restrict write access to authenticated users
- Input validation on both client and server
- CORS enabled for cross-origin requests

## Performance Optimizations

- Events automatically expire after 2 hours
- Firestore queries limited to 500 most recent events
- Map marker clustering for better performance
- Distance-based filtering for event retrieval

## License

MIT License

## Support

For issues or questions, please open an issue on the project repository.
