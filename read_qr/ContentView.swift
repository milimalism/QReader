//
//  ContentView.swift
//  read_qr
//
//  Created by Mythili Mulani on 11/08/25.
//

import SwiftUI
import AppKit
import Vision

struct ContentView: View {
    @State private var image = NSImage()
    @State private var url: URL? = nil

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack {
            Button {
                if ScreenshotQRCode(){
                    image = RetrieveImage()
                    print("taken screenshot")
                    decodeQrFromImage(from: image)
                }
            } label: {
                Text("Select QR code")
            }
            
            Text("Captured QR")
            
            Image(nsImage: image)
        }.padding()
        
    }
    
    func ScreenshotQRCode() -> Bool {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-sc"]
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return status == 0
    }
    
    func RetrieveImage() -> NSImage {
        let pasteboard = NSPasteboard.general
        guard pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else {
            return NSImage()
        }
        guard let image = NSImage(pasteboard: pasteboard) else {
            return NSImage()
        }
        
        return image
    }
    
    //    1. Create a VNDetectBarcodesRequest for qr code recognition, ensure to set the symbologies as .qr
    //    2. Receive the results of the qr detection request as arrays of VNBarcodeObservation objects.
    //    The VNBarcodeObservation object contains:
    //      An recognized payloadString (payloadStringValue) <- the decoding we want!!!
    //    3. Use a handler to create a request and send a request for qr detection.

    //
    //
    //    Create a request for image processing, and send a request for text recognition.
        func decodeQrFromImage(from image: NSImage) {
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    print("Could not get CGImage from NSImage")
                    return
                }
            print("got image")

            let request = VNDetectBarcodesRequest { request, error in // 1
                guard let observations = request.results as? [VNBarcodeObservation] else { return } // 2

                for observation in observations {
                    if let payload = observation.payloadStringValue {
                                    print("QR Code String: \(payload)")
                                }
                }
            }

            request.symbologies = [.qr] // Only look for QR codes

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:]) // 3
            try? handler.perform([request]) // 3
        }
    
}
