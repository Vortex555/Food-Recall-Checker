import AVFoundation

@MainActor
@Observable
final class CameraPermissionManager {
    var authorizationStatus: AVAuthorizationStatus

    init() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestAccess() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        authorizationStatus = granted ? .authorized : .denied
    }
}
