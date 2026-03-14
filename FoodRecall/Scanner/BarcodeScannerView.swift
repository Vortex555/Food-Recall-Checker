import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewRepresentable {
    let isScanning: Bool
    let onBarcodeDetected: (String) -> Void

    func makeUIView(context: Context) -> BarcodeScannerUIView {
        let view = BarcodeScannerUIView()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: BarcodeScannerUIView, context: Context) {
        if isScanning {
            uiView.startScanning()
        } else {
            uiView.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeDetected: onBarcodeDetected)
    }

    class Coordinator: NSObject, BarcodeScannerDelegate {
        let onBarcodeDetected: (String) -> Void
        private var lastDetectedBarcode: String?
        private var lastDetectionTime: Date?

        init(onBarcodeDetected: @escaping (String) -> Void) {
            self.onBarcodeDetected = onBarcodeDetected
        }

        func didDetectBarcode(_ barcode: String) {
            let now = Date()
            if barcode == lastDetectedBarcode,
               let lastTime = lastDetectionTime,
               now.timeIntervalSince(lastTime) < 3.0 {
                return
            }
            lastDetectedBarcode = barcode
            lastDetectionTime = now
            onBarcodeDetected(barcode)
        }
    }
}

protocol BarcodeScannerDelegate: AnyObject {
    func didDetectBarcode(_ barcode: String)
}

class BarcodeScannerUIView: UIView {
    weak var delegate: BarcodeScannerDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "com.foodrecall.scanner")
    private var isConfigured = false

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    func startScanning() {
        if !isConfigured {
            configureCaptureSession()
        }
        sessionQueue.async { [weak self] in
            guard let self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    private func configureCaptureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        captureSession.beginConfiguration()

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.ean13, .ean8, .upce]
        }

        captureSession.commitConfiguration()

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds
        layer.addSublayer(preview)
        previewLayer = preview

        isConfigured = true
    }
}

extension BarcodeScannerUIView: @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = object.stringValue else {
            return
        }
        delegate?.didDetectBarcode(barcode)
    }
}
