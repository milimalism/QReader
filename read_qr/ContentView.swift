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
    
}
