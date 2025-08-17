//
//  QRDecoder.swift
//  read_qr
//
//  Created by Mythili Mulani on 14/08/25.
//
import AppKit
import Vision

struct QRDecoder {
    
    
    //    1. Create a VNDetectBarcodesRequest for qr code recognition, ensure to set the symbologies as .qr
    //    2. Receive the results of the qr detection request as arrays of VNBarcodeObservation objects.
    //    The VNBarcodeObservation object contains:
    //      An recognized payloadString (payloadStringValue) <- the decoding we want!!!
    //    3. Use a handler to create a request and send a request for qr detection
    static func decode(from image: NSImage) -> String? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        var qrLink: String? = nil
        let request = VNDetectBarcodesRequest { request, error in // 1
            guard let observations = request.results as? [VNBarcodeObservation] else { return } // 2

            for observation in observations {
                if let payload = observation.payloadStringValue {
                        print("QR Code String: \(payload)")
                        qrLink = payload
                        return
                    }
            }
        }

        request.symbologies = [.qr] // Only look for QR codes

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request]) // 3
    
        return qrLink
    }
    
    static func retrieveImage(from url: URL) -> NSImage? {
        NSImage(contentsOf: url)
    }
    
    static func screenshotToTempFile() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("screenshot.png")
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-s", fileURL.path]  // -s to allow selection, save to the temp filepath
        
        task.launch()
        task.waitUntilExit()
        
        return (task.terminationStatus == 0) ? fileURL : nil
    }
}
