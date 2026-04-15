//
//  OCRManager.swift
//  Fuwari
//
//  Performs text recognition on captured images using the Vision framework.
//

import Cocoa
import Vision

final class OCRManager: NSObject {

    static let shared = OCRManager()

    enum OCRError: Error, LocalizedError {
        case requestFailed
        case noText

        var errorDescription: String? {
            switch self {
            case .requestFailed:
                return "Failed to perform text recognition."
            case .noText:
                return "No recognizable text was found in the image."
            }
        }
    }

    /// Recognize text in the given image. The completion is called on the main queue.
    func recognizeText(in cgImage: CGImage, completion: @escaping (Result<String, Error>) -> Void) {
        let request = VNRecognizeTextRequest { request, error in
            let deliver: (Result<String, Error>) -> Void = { result in
                DispatchQueue.main.async { completion(result) }
            }

            if let error = error {
                deliver(.failure(error))
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                deliver(.failure(OCRError.requestFailed))
                return
            }
            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            if text.isEmpty {
                deliver(.failure(OCRError.noText))
            } else {
                deliver(.success(text))
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        if #available(macOS 11.0, *) {
            // Prefer the user's preferred languages, falling back to English + Japanese.
            let preferred = Locale.preferredLanguages.prefix(2)
            let languages = Array(preferred) + ["en-US", "ja-JP"]
            request.recognitionLanguages = Array(NSOrderedSet(array: languages)) as? [String] ?? ["en-US", "ja-JP"]
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    /// Copies the given text to the general pasteboard.
    func copyToPasteboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
