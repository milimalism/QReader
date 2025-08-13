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
    @State private var qrURL: URL? = nil
    @State private var errorMessage: String? = nil

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack {
            Button {
                qrURL = nil
                errorMessage = nil
                
                guard let screenshotPath = screenshotToTempFile() else {
                    errorMessage = "Screenshot error"
                    return
                }
                
                guard let screenshotImage = RetrieveImage(url: screenshotPath) else {
                    errorMessage = "Could not load screenshot."
                    try? FileManager.default.removeItem(at: screenshotPath)
                    return
                }
                
                image = screenshotImage
                guard let qrString = decodeQrFromImage(from: screenshotImage) else {
                   errorMessage = "No QR code detected."
                   try? FileManager.default.removeItem(at: screenshotPath)
                   return
               }

                guard let url = URL(string: qrString) else {
                   errorMessage = "QR code is not a valid URL."
                   try? FileManager.default.removeItem(at: screenshotPath)
                   return
                }
                qrURL = url
            } label: {
                Text("Select QR code")
            }
            .padding()
            
            Text("Captured QR")
            
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            
            Button {
                if let url = qrURL {
                    openURL(url)
                }
            } label: {
                Text("Open url!")
            }
            .disabled(qrURL == nil)
        }.padding()
        
    }
    
    func screenshotToTempFile() -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("screenshot.png")
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-s", fileURL.path]  // -s to allow selection, save to the temp filepath
        
        task.launch()
        task.waitUntilExit()
        print("Task terminaltion status \(task.terminationStatus)")
        return (task.terminationStatus == 0) ? fileURL : nil
    }
    
    func RetrieveImage(url: URL) -> NSImage? {
        return NSImage(contentsOf: url)
    }
    
    //    1. Create a VNDetectBarcodesRequest for qr code recognition, ensure to set the symbologies as .qr
    //    2. Receive the results of the qr detection request as arrays of VNBarcodeObservation objects.
    //    The VNBarcodeObservation object contains:
    //      An recognized payloadString (payloadStringValue) <- the decoding we want!!!
    //    3. Use a handler to create a request and send a request for qr detection

    //
    //
    //    Create a request for image processing, and send a request for text recognition.
    func decodeQrFromImage(from image: NSImage) -> String? {
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    print("Could not get CGImage from NSImage")
                    return nil
                }
            print("got image")
        
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

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:]) // 3
            try? handler.perform([request]) // 3
        
            return qrLink
        }
    
}
