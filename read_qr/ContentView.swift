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
                
                guard let screenshotPath = QRDecoder.screenshotToTempFile() else {
                    errorMessage = "Screenshot error"
                    return
                }
                
                guard let screenshotImage = QRDecoder.retrieveImage(from: screenshotPath) else {
                    errorMessage = "Could not load screenshot."
                    try? FileManager.default.removeItem(at: screenshotPath)
                    return
                }
                
                image = screenshotImage
                guard let qrString = QRDecoder.decode(from: screenshotImage) else {
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
                     .font(.system(size: 13, weight: .regular))
                     .foregroundColor(Color(red: 0.23, green: 0.23, blue: 0.23)) // Soft charcoal
                     .padding(.horizontal, 20)
                     .padding(.vertical, 10)
                     .frame(maxWidth: .infinity)
                     .background(Color(red: 0.66, green: 0.75, blue: 0.60)) // Soft mint
                     .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .buttonStyle(PlainButtonStyle())
            
            
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
                Text("Open URL!")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(qrURL == nil ?
                        Color(red: 0.63, green: 0.60, blue: 0.58) : // Light gray when disabled
                        Color(red: 0.23, green: 0.23, blue: 0.23)) // Soft charcoal when enabled
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(qrURL == nil ?
                        Color(red: 0.83, green: 0.82, blue: 0.81) :
                        Color(red: 0.66, green: 0.75, blue: 0.60))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(qrURL == nil)
            
            
        }
        .padding()
        .background(
            Color(red: 0.98, green: 0.97, blue: 0.96)
        )
        
    }
}
