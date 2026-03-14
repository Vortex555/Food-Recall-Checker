import SwiftUI
import SwiftData

struct ScanTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScannerViewModel()
    @State private var cameraPermission = CameraPermissionManager()

    var body: some View {
        NavigationStack {
            ZStack {
                switch cameraPermission.authorizationStatus {
                case .authorized:
                    scannerView
                case .notDetermined:
                    requestPermissionView
                case .denied, .restricted:
                    permissionDeniedView
                @unknown default:
                    requestPermissionView
                }

                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("Scan Food")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showResult) {
                viewModel.resetScanner()
            } content: {
                if let result = viewModel.result {
                    ScanResultView(match: result)
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil; viewModel.resetScanner() } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                    viewModel.resetScanner()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var scannerView: some View {
        ZStack {
            BarcodeScannerView(isScanning: viewModel.isScanning) { barcode in
                Task {
                    await viewModel.handleBarcode(barcode, context: modelContext)
                }
            }
            .ignoresSafeArea()

            VStack {
                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 280, height: 160)
                    .shadow(color: .black.opacity(0.3), radius: 8)

                Spacer()

                Text("Point camera at a food barcode")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
            }
        }
    }

    private var requestPermissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Camera Access Required")
                .font(.title2.bold())

            Text("Food Recall needs camera access to scan barcodes on food products.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Enable Camera") {
                Task { await cameraPermission.requestAccess() }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Camera Access Denied")
                .font(.title2.bold())

            Text("Please enable camera access in Settings to scan barcodes.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Checking recalls...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
