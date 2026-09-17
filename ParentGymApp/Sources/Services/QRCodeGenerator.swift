//
//  QRCodeGenerator.swift
//
//  Turns a piece of text (the child's unique check-in code) into a QR
//  code image, entirely on-device using Apple's built-in CoreImage filter.
//  No network call or third-party library is needed for this.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

enum QRCodeGenerator {

    /// Generates a crisp QR code image for the given text.
    /// Returns nil if, for some unexpected reason, the image can't be built.
    static func image(for text: String) -> Image? {
        // CIFilter.qrCodeGenerator() is a built-in Apple filter that turns
        // raw data into a QR code bitmap.
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M" // Medium error-correction, a good default.

        guard let outputImage = filter.outputImage else { return nil }

        // The generated image is tiny (like 25x25 pixels), so we scale it
        // up so it stays sharp on screen instead of looking blurry.
        let scale: CGFloat = 10
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return Image(decorative: cgImage, scale: 1.0)
    }
}
