import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var firebaseService: FirebaseService
    @StateObject private var viewModel = MapViewModel()
    @State private var showReportSheet = false

    var body: some View {
        ZStack {
            MapView(events: viewModel.events, userLocation: locationManager.location)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button(action: {
                        showReportSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 56, height: 56)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            locationManager.requestPermission()
            viewModel.startListening(firebaseService: firebaseService)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportSheet(
                userLocation: locationManager.location,
                firebaseService: firebaseService,
                isPresented: $showReportSheet
            )
        }
    }
}
